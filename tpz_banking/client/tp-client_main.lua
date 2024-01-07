ClientData = { HasBankOpen = false, CurrentBankName = nil, Loaded = false }

-----------------------------------------------------------
--[[ Base Events & Threads ]]--
-----------------------------------------------------------

-- Requests when devmode set to false and character is selected.
AddEventHandler("tpz_core:isPlayerReady", function()
    TriggerServerEvent('tpz_banking:requestBankingInformation')
end)

-- Requests when devmode set to true.
if Config.DevMode then
    Citizen.CreateThread(function ()

        Wait(2000)
        TriggerServerEvent('tpz_banking:requestBankingInformation')
    end)
end

if Config.DoorSystemSetDoorStates then

    Citizen.CreateThread(function()
        for door, state in pairs(DoorHashesList) do
            if not IsDoorRegisteredWithSystem(door) then Citizen.InvokeNative(0xD99229FE93B46286, door, 1, 1, 0, 0, 0, 0)  end
            DoorSystemSetDoorState(door, state)
        end
    end)

end

-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

RegisterNetEvent("tpz_banking:setPlayerAsLoaded")
AddEventHandler("tpz_banking:setPlayerAsLoaded", function()
    ClientData.Loaded = true
end)

---------------------------------------------------------------
-- Threads
---------------------------------------------------------------

Citizen.CreateThread(function()
    RegisterActionPrompt()

    while true do
        Citizen.Wait(0)

        local sleep  = true

        local player = PlayerPedId()

        local coords = GetEntityCoords(PlayerPedId())
        local hour   = GetClockHours()
        local isDead = IsEntityDead(player)

        if not isDead and not ClientData.HasBankOpen and ClientData.Loaded then

            for index, bankConfig in pairs(Config.Banks) do

                local coordsDist = vector3(coords.x, coords.y, coords.z)
                local coordsStore = vector3(bankConfig.Coords.x, bankConfig.Coords.y, bankConfig.Coords.z)
                local distance = #(coordsDist - coordsStore)

                local invalidHour = (hour >= bankConfig.Hours.Duration.pm or hour < bankConfig.Hours.Duration.am)

                if ( distance > Config.NPCRenderingDistance ) or (bankConfig.Hours.Enabled and invalidHour) then
                    
                    if Config.Banks[index].NPC then
                        DeleteEntity(Config.Banks[index].NPC)
                        DeletePed(Config.Banks[index].NPC)
                        SetEntityAsNoLongerNeeded(Config.Banks[index].NPC)
                        Config.Banks[index].NPC = nil
                    end

                end

                local isBankAvailable = true

                if bankConfig.Hours.Enabled and invalidHour then
                    isBankAvailable = false
                end

                if isBankAvailable then

                    if distance <= Config.NPCRenderingDistance and not Config.Banks[index].NPC and bankConfig.NPCData.Enabled  then
                        SpawnNPC(index)
                    end

                    if distance <= bankConfig.ActionDistance then
                        sleep = false

                        local label = CreateVarString(10, 'LITERAL_STRING', Config.PromptKey.label)
        
                        PromptSetActiveGroupThisFrame(Prompts, label)
    
                        if PromptHasHoldModeCompleted(PromptsList) then

                            OpenBankingNUI(index)

                            Wait(1000)
                        end
                    end

                end
            end
        end

        if sleep then
            Citizen.Wait(1000)
        end
    end
end)
