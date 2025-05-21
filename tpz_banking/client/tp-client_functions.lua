
local Prompts     = GetRandomIntInRange(0, 0xffffff)
local PromptsList = {}

--[[-------------------------------------------------------
 Prompts
]]---------------------------------------------------------

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

function GetPromptData()
    return Prompts, PromptsList
end

--[[-------------------------------------------------------
 Blips Management
]]---------------------------------------------------------

function AddBlip(location, StatusType)

    if Config.Banks[location].BlipData then

        local BlipData = Config.Banks[location].BlipData

        local sprite, blipModifier = BlipData.Sprite, 'BLIP_MODIFIER_MP_COLOR_32'

        if BlipData.OpenBlipModifier then
            blipModifier = BlipData.OpenBlipModifier
        end

        if StatusType == 'CLOSED' then
            sprite = BlipData.DisplayClosedHours.Sprite
            blipModifier = BlipData.DisplayClosedHours.BlipModifier
        end
        
        Config.Banks[location].BlipHandle = N_0x554d9d53f696d002(1664425300, Config.Banks[location].Coords.x, Config.Banks[location].Coords.y, Config.Banks[location].Coords.z)

        SetBlipSprite(Config.Banks[location].BlipHandle, sprite, 0)
        SetBlipScale(Config.Banks[location].BlipHandle, 0.2)

        Citizen.InvokeNative(0x662D364ABF16DE2F, Config.Banks[location].BlipHandle, GetHashKey(blipModifier))

        Config.Banks[location].BlipHandleModifier = blipModifier

        Citizen.InvokeNative(0x9CB1A1623062F402, Config.Banks[location].BlipHandle, BlipData.Name)

    end
end


--[[-------------------------------------------------------
 NPC Management
]]---------------------------------------------------------

RemoveEntityProperly = function(entity, objectHash)
	DeleteEntity(entity)
	DeletePed(entity)
	SetEntityAsNoLongerNeeded( entity )

	if objectHash then
		SetModelAsNoLongerNeeded(objectHash)
	end
end

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

    local npc = CreatePed(v.Model, v.Coords.x, v.Coords.y, v.Coords.z, v.Coords.h, false, true, true, true)
    Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
    SetEntityCanBeDamaged(npc, false)
    SetEntityInvincible(npc, true)
    Wait(500)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    Config.Banks[index].NPC = npc
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

function Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

--[[-------------------------------------------------------
 Events
]]---------------------------------------------------------

AddEventHandler("onResourceStop", function(resourceName)

    if resourceName ~= GetCurrentResourceName() then
        return
    end

    Citizen.InvokeNative(0x00EDE88D4D13CF59, Prompts) -- UiPromptDelete

    PromptsList      = nil

    for i, v in pairs(Config.Banks) do

        if v.BlipHandle then
            RemoveBlip(v.BlipHandle)
        end

        if v.NPC then
            RemoveEntityProperly(v.NPC, GetHashKey(v.NPCData.Model))
        end

    end

end)
