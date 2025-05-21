
local PlayerData = { 
    IsBusy = false, 
    Loaded = false,
}

---------------------------------------------------------------
--[[ Local Functions ]]--
---------------------------------------------------------------

local function IsBankConsideredOpen(location)

    if not location.Hours.Enabled then
        return true
    end

    local hour = GetClockHours()
    
    if location.Hours.Opening < location.Hours.Closing then
        -- Normal hours: Opening and closing on the same day (e.g., 08 to 20)
        if hour < location.Hours.Opening or hour >= location.Hours.Closing then
            return false
        end
    else
        -- Overnight hours: Closing time is on the next day (e.g., 21 to 05)
        if hour < location.Hours.Opening and hour >= location.Hours.Closing then
            return false
        end
    end

    return true

end

---------------------------------------------------------------
--[[ Functions ]]--
---------------------------------------------------------------

function GetPlayerData()
    return PlayerData
end

-----------------------------------------------------------
--[[ Base Events & Threads ]]--
-----------------------------------------------------------

AddEventHandler("tpz_core:isPlayerReady", function()
    Wait(2000)
    TriggerServerEvent("tpz_banking:server:isPlayerReady")
end)

-- Requests when devmode set to true.
if Config.DevMode then
    Citizen.CreateThread(function ()
        TriggerServerEvent("tpz_banking:server:isPlayerReady")
    end)
end

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

        if not isDead and not PlayerData.IsBusy then

            for index, location in pairs(Config.Banks) do

                local coordsDist  = vector3(coords.x, coords.y, coords.z)
                local coordsLoc = vector3(location.Coords.x, location.Coords.y, location.Coords.z)
                local distance    = #(coordsDist - coordsLoc)

                local isAllowed   = IsBankConsideredOpen(location)

                if location.BlipData.Enabled then
    
                    local ClosedHoursData = location.BlipData.DisplayClosedHours

                    if isAllowed ~= location.IsAllowed and location.BlipHandle then

                        RemoveBlip(location.BlipHandle)
                        
                        location.BlipHandle = nil
                        location.IsAllowed  = isAllowed

                    end

                    if (isAllowed and location.BlipHandle == nil) or (not isAllowed and ClosedHoursData and ClosedHoursData.Enabled and location.BlipHandle == nil ) then
                        local blipModifier = isAllowed and 'OPEN' or 'CLOSED'
                        AddBlip(index, blipModifier)

                        location.IsAllowed = isAllowed
                    end

                end

                if (distance > Config.NPCRenderingDistance or not isAllowed) and (location.NPC ~= nil) then
                    RemoveEntityProperly(location.NPC, GetHashKey(location.NPCData.Model))
                    location.NPC = nil
                end

                if isAllowed then

                    if distance <= Config.NPCRenderingDistance and location.NPCData.Enabled and location.NPC == nil then
                        SpawnNPC(index)
                    end

                    if distance <= location.ActionDistance then
                        sleep = false

                        local Prompts, PromptsList = GetPromptData()
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

if Config.DoorSystemSetDoorStates then

    Citizen.CreateThread(function()

        local DoorHashesList = GetDoorHashesList() -- tp-client_doorhashes.lua

        for door, state in pairs(DoorHashesList) do

            if not IsDoorRegisteredWithSystem(door) then 
                Citizen.InvokeNative(0xD99229FE93B46286, door, 1, 1, 0, 0, 0, 0)  
            end

            DoorSystemSetDoorState(door, state)

        end

    end)

end