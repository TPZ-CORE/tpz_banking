
--[[-------------------------------------------------------
 Handlers
]]---------------------------------------------------------

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    for i, v in pairs(Config.Banks) do
        if v.BlipHandle then
            RemoveBlip(v.BlipHandle)
        end

        if v.NPC then
            DeleteEntity(v.NPC)
            DeletePed(v.NPC)
            SetEntityAsNoLongerNeeded(v.NPC)
        end
    end

    ClearPedTasks(PlayerPedId())

end)

--[[-------------------------------------------------------
 Prompts
]]---------------------------------------------------------

Prompts       = GetRandomIntInRange(0, 0xffffff)
PromptsList   = {}

RegisterActionPrompt = function()

    local str      = Locales['PROMPT_ACTION']
    local keyPress = Config.PromptKey.key

    local dPrompt = PromptRegisterBegin()
    PromptSetControlAction(dPrompt, keyPress)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(dPrompt, str)
    PromptSetEnabled(dPrompt, 1)
    PromptSetVisible(dPrompt, 1)
    PromptSetStandardMode(dPrompt, 1)
    PromptSetHoldMode(dPrompt, 1000)
    PromptSetGroup(dPrompt, Prompts)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, dPrompt, true)
    PromptRegisterEnd(dPrompt)

    PromptsList = dPrompt
end

--[[-------------------------------------------------------
 Blips Management
]]---------------------------------------------------------

Citizen.CreateThread(function ()
    for index, blip in pairs (Config.Banks) do

        if blip.BlipData and blip.BlipData.Enabled then

            local blipHandle = N_0x554d9d53f696d002(1664425300, blip.Coords.x, blip.Coords.y, blip.Coords.z)
    
            SetBlipSprite(blipHandle, blip.BlipData.Sprite, 1)
            SetBlipScale(blipHandle, 0.1)
            Citizen.InvokeNative(0x9CB1A1623062F402, blipHandle, blip.BlipData.Title)

                    
            Config.Banks[index].BlipHandle = blipHandle

        end

    end
end)

--[[-------------------------------------------------------
 NPC Management
]]---------------------------------------------------------

LoadModel = function(model)
    local model = GetHashKey(model)
    RequestModel(model)

    while not HasModelLoaded(model) do RequestModel(model)
        Citizen.Wait(100)
    end
end

SpawnNPC = function(index)
    local v = Config.Banks[index].NPCData

    LoadModel(v.Model)

    if v.Enabled then
        local npc = CreatePed(v.Model, v.Coords.x, v.Coords.y, v.Coords.z, v.Coords.h, false, true, true, true)
        Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
        SetEntityCanBeDamaged(npc, false)
        SetEntityInvincible(npc, true)
        Wait(500)
        FreezeEntityPosition(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        Config.Banks[index].NPC = npc
    end
end

--[[-------------------------------------------------------
 General
]]---------------------------------------------------------

-- @GetTableLength returns the length of a table.
function GetTableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

