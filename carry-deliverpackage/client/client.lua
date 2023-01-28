local holdingProp = false
local prop = nil

function GetPlayerId()
    local player = PlayerId()
    return player
end

function CollectProp()
    -- code to turn prop into a collectable item
    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
    prop = CreateObject(GetHashKey("prop_cs_box_clothes"), x, y, z-1, 1, 1, 1)
    TriggerEvent("mythic_notify:client:SendAlert", { type = "inform", text = "You have delivered a package", length = 10000 })
end

RegisterCommand("pack", function()
    if not holdingProp then
        holdingProp = true
        prop = CreateObject(GetHashKey("prop_cs_box_clothes"), GetPlayerPed(GetPlayerId()), 1, 1, 1, 1, 0)
        AttachEntityToEntity(prop, GetPlayerPed(GetPlayerId()), GetPedBoneIndex(GetPlayerPed(GetPlayerId()), 28422), -0.05, 0.0, -0.10, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        RequestAnimDict("anim@heists@box_carry@")
        while not HasAnimDictLoaded("anim@heists@box_carry@") do
            Citizen.Wait(0)
        end
        TaskPlayAnim(GetPlayerPed(GetPlayerId()), "anim@heists@box_carry@", "idle", 8.0, 8.0, -1, 50, 0, false, false, false)
    else
        holdingProp = false
        DetachEntity(prop, 1, 1)
        DeleteObject(prop)
        ClearPedTasks(GetPlayerPed(GetPlayerId()))
    end
end, false)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if holdingProp then
            if IsControlJustReleased(1, 73) then
                RequestAnimDict("pickup_object")
                while not HasAnimDictLoaded("pickup_object") do
                    Citizen.Wait(0)
                end
                TaskPlayAnim(GetPlayerPed(GetPlayerId()), "pickup_object", "pickup_low", 8.0, 8.0, -1, 50, 0, false, false, false)
                Wait(1000)
                ClearPedTasks(GetPlayerPed(GetPlayerId()))
                holdingProp = false
                DetachEntity(prop, 1, 1)
                CollectProp()
                DeleteObject(prop)
            end
        end
    end
end)
