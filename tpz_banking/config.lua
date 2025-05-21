Config = {}

Config.DevMode    = false
Config.Debug      = true

Config.PromptKey = { key = 0x760A9C6F, label = 'Banking Account ' } -- G

-- The following is only when a notification sent while Banking is open (It has its own notification system).
Config.NotificationColors = {
    ['error']   = "rgba(255, 0, 0, 0.79)",
    ['success'] = "rgba(0, 255, 0, 0.79)",
    ['info']    = "rgba(0, 0, 255, 0.79)"
}


-----------------------------------------------------------
--[[ General ]]--
-----------------------------------------------------------

-- The following option is saving all the data before server restart hours
-- (2-3 Minutes atleast before server restart is mostly preferred).
Config.RestartHours = { "7:57" , "13:57", "19:57", "1:57"}

-- As default, we save all data every 10 minutes to avoid data loss in case for server crashes.
-- @param Enabled : Set to false do disable saving every x minutes.
-- @param Duration : Time in minutes.
Config.SaveDataRepeatingTimer = { Enabled = true, Duration = 10 }

-- NPC Rendering Distance which is deleting the npc when being away from the bank.
Config.NPCRenderingDistance = 20.0

-- The year of your server which is based and playing on.
Config.Year = 1890

-- The cost for a player to create a bank account (one-time).
-- @param account : In case the money is NOT an item, you can use "CASH" or "GOLD".
-- @param cost    : The registration cost.
Config.BankRegistryCost = { Account = 'CASH', Cost = 5 }

-- The transaction action limitations, to prevent players to deposit, withdraw or transfer
-- lower than the configurable amount.
Config.TransactionLimitations = { 
    Deposit  = { ['CASH'] = 20, ['GOLD'] = 1 }, -- Minimum
    Transfer = 20, -- Minimum (ONLY CASH AVAILABLE)
}

-- The transfer transaction action fees.
-- Set Config.TransferTransactionFees = 0 to disable.
Config.TransferTransactionFees = 10 -- % (ONLY CASH AVAILABLE)

-- If you don't want to include first IBAN letters, set it the text to empty ( Config.FirstIBANLetters = "" )
Config.FirstIBANLetters = "GR"

-- Unlocking Bank Doors.
Config.DoorSystemSetDoorStates = true

Config.Options = {
    ['TRANSFERS'] = true, -- Set to false to prevent the players to perform transfers.
}

---------------------------------------------------------------
-- Locations
---------------------------------------------------------------


Config.Banks = {

    ['VALENTINE'] = {

        Name = "Valentine Bank",

        Coords = {x = -308.50, y = 776.24, z = 118.75},
        ActionDistance = 1.2,

        Hours = { Enabled = true, Opening = 7, Closing = 21 },

        BlipData = {
            Enabled = true,
            Title   = "Valentine Bank",
            Sprite  = -2128054417,

            OpenBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            DisplayClosedHours = { Enabled = true, Sprite = -2128054417, BlipModifier = "BLIP_MODIFIER_MP_COLOR_2" },
        },

        NPCData = {
            Enabled = true,
            Model = "S_M_M_BankClerk_01",

            Coords = { x = -308.02, y = 773.82, z = 116.7, h = 18.69},
        },

    },

    ['RHODES'] = {
        Name = "Rhodes Bank",

        Coords = {x = 1294.14, y = -1303.06, z = 77.04},
        ActionDistance = 1.2,

        Hours = { Enabled = true, Opening = 7, Closing = 21 },

        BlipData = {
            Enabled = true,
            Title   = "Rhodes Bank",
            Sprite  = -2128054417,

            OpenBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            DisplayClosedHours = { Enabled = true, Sprite = -2128054417, BlipModifier = "BLIP_MODIFIER_MP_COLOR_2" },
        },

        NPCData = {
            Enabled = true,
            Model = "S_M_M_BankClerk_01",

            Coords = { x = 1292.84, y = -1304.74, z = 76.04, h = 327.08},
        },

    },

    ['SAINTDENIS'] = {
        Name = "Saint Denis Bank",

        Coords = {x = 2644.08, y = -1292.21, z = 52.29},
        ActionDistance = 1.2,

        Hours = { Enabled = true, Opening = 7, Closing = 21 },

        BlipData = {
            Enabled = true,
            Title   = "Saint Denis Bank",
            Sprite  = -2128054417,

            OpenBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            DisplayClosedHours = { Enabled = true, Sprite = -2128054417, BlipModifier = "BLIP_MODIFIER_MP_COLOR_2" },
        },

        NPCData = {
            Enabled = true,
            Model = "S_M_M_BankClerk_01",

            Coords = { x = 2645.12, y = -1294.37, z = 51.25, h = 30.64},
        },

    },

    ['BLACKWATER'] = {
        Name = "Blackwater Bank",

        Coords = {x = -813.18, y = -1277.60, z = 43.68},
        ActionDistance = 1.2,

        Hours = { Enabled = true, Opening = 7, Closing = 21 },

        BlipData = {
            Enabled = true,
            Title   = "Blackwater Bank",
            Sprite  = -2128054417,

            OpenBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            DisplayClosedHours = { Enabled = true, Sprite = -2128054417, BlipModifier = "BLIP_MODIFIER_MP_COLOR_2" },
        },

        NPCData = {
            Enabled = true,
            Model = "S_M_M_BankClerk_01",

            Coords = { x = -813.18, y = -1275.42, z = 42.64, h = 176.86},
        },

    },

    ['ARMADILLO'] = {
        Name = "Armadillo Bank",

        Coords = {x = -3664.05, y = -2626.57, z = -13.58},
        ActionDistance = 1.2,

        Hours = { Enabled = true, Opening = 7, Closing = 21 },

        BlipData = {
            Enabled = true,
            Title   = "Armadillo Bank",
            Sprite  = -2128054417,

            OpenBlipModifier = 'BLIP_MODIFIER_MP_COLOR_32',
            DisplayClosedHours = { Enabled = true, Sprite = -2128054417, BlipModifier = "BLIP_MODIFIER_MP_COLOR_2" },
        },

        NPCData = {
            Enabled = true,
            Model = "S_M_M_BankClerk_01",

            Coords = { x = -3663.98, y = -2628.69, z = -14.58, h = 358.15},
        },

    },
}


-----------------------------------------------------------
--[[ Discord Webhook Logs ]]--
-----------------------------------------------------------

Config.DiscordWebhooking = {
    Enabled = false,
    Url = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", -- The discord webhook url.
    Color = 10038562,
}
