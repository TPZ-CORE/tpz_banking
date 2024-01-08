
Config = {}

Config.DevMode    = true
Config.PromptKey  = { key = 0x760A9C6F, label = 'Banking Account ' } -- G

-----------------------------------------------------------
--[[ Transfers ]]--
-----------------------------------------------------------

-- VAT will be only for bank account money transfers.
Config.BankTransfersVAT = {
    MinimumAmount = 10, -- The minimum transfer amount for sending to another account (Don't use less than 10.).
    VAT = 10,
}

-----------------------------------------------------------
--[[ General ]]--
-----------------------------------------------------------

-- The following is only when a notification sent while Banking is open (It has its own notification system).
Config.NotificationColors = {
    ['error']   = "rgba(255, 0, 0, 0.79)",
    ['success'] = "rgba(0, 255, 0, 0.79)",
    ['info']    = "rgba(0, 0, 255, 0.79)"
}

-- NPC Rendering Distance which is deleting the npc when being away from the bank.
Config.NPCRenderingDistance = 20.0

-- The cost for a player registering to a bank account (Bank Location) for first time.
Config.BankRegistryCost = 5

-- Unlocking Bank Doors.
Config.DoorSystemSetDoorStates = true

-- The year of your server which is based and playing on.
Config.Year = 1890

-- (!) Make sure the name of the bank is the same as your Config.Banks.
-- DO NOT Change without knowledge.

-- The following option is based for tpz_society and only, in what bank should the players
-- receive their salaries (if society salary is enabled).
-- if the player has not been registered to that bank, the salary will be lost.
Config.DefaultBankSalaryReceive = "valentine"

-----------------------------------------------------------
--[[ Webhooking ]]--
-----------------------------------------------------------

Config.Webhooking = {

    Enabled = true,
    Url = "https://discord.com/api/webhooks/1193701765053427802/aTD1lDDFCbVUk7DsMgl3qRkDvHNOwVl_RYMh0bbP2wE498CNcsgqC_z7X2m1jS0ul4Xx", -- The discord webhook url.
    Color = 10038562,
}

-----------------------------------------------------------
--[[ Bank Locations ]]--
-----------------------------------------------------------

Config.Banks = {
    ['valentine'] = {
        name = "Valentine Bank",

        Coords = {x = -308.50, y = 776.24, z = 118.75},

        city = "Valentine",

        Hours = {
            Enabled = true,
            Duration = {am = 7, pm = 21},
        },


        Blips = {
            Enabled = true,
            Sprite = -2128054417,
        },

        BlipData = {
            Enabled = true,
            Title   = "Valentine Bank",
            Sprite  = -2128054417,
        },

        NPCData = {
            Enabled = true,
            Model = "S_M_M_BankClerk_01",

            Coords = { x = -308.02, y = 773.82, z = 116.7, h = 18.69},
        },

        ActionDistance = 1.5,
    },

    ['blackwater'] = {
        name = "Blackwater Bank",

        Coords = {x = -813.18, y = -1277.60, z = 43.68},

        city = "Blackwater",

        Hours = {
            Enabled = true,
            Duration = {am = 7, pm = 21},
        },

        BlipData = {
            Enabled = true,
            Title   = "Blackwater Bank",
            Sprite  = -2128054417,
        },

        NPCData = {
            Enabled = true,
            Model = "S_M_M_BankClerk_01",

            Coords = { x = -813.18, y = -1275.42, z = 42.64, h = 176.86},
        },

        ActionDistance = 1.5,
    },

    ['saintdenis'] = {
        name = "Saint Denis Bank",

        Coords = {x = 2644.08, y = -1292.21, z = 52.29},

        city = "Saint Denis",

        Hours = {
            Enabled = true,
            Duration = {am = 7, pm = 21},
        },

        BlipData = {
            Enabled = true,
            Title   = "Saint Denis Bank",
            Sprite  = -2128054417,
        },

        NPCData = {
            Enabled = true,
            Model = "S_M_M_BankClerk_01",

            Coords = { x = 2645.12, y = -1294.37, z = 51.25, h = 30.64},
        },

        ActionDistance = 1.5,
    },

    ['rhodes'] = {
        name = "Rhodes Bank",

        Coords = {x = 1294.14, y = -1303.06, z = 77.04},

        city = "Rhodes",

        Hours = {
            Enabled = true,
            Duration = {am = 7, pm = 21},
        },

        BlipData = {
            Enabled = true,
            Title   = "Rhodes Bank",
            Sprite  = -2128054417,
        },

        NPCData = {
            Enabled = true,
            Model = "S_M_M_BankClerk_01",

            Coords = { x = 1292.84, y = -1304.74, z = 76.04, h = 327.08},
        },

        ActionDistance = 1.5,
    },

    ['armadillo'] = {
        name = "Armadillo Bank",

        Coords = {x = -3664.05, y = -2626.57, z = -13.58},

        city = "Armadillo",

        Hours = {
            Enabled = true,
            Duration = {am = 7, pm = 21},
        },

        BlipData = {
            Enabled = true,
            Title   = "Armadillo Bank",
            Sprite  = -2128054417,
        },

        NPCData = {
            Enabled = true,
            Model = "S_M_M_BankClerk_01",

            Coords = { x = -3663.98, y = -2628.69, z = -14.58, h = 358.15},
        },

        ActionDistance = 1.5,
    }
}
