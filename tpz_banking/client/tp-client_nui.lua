

local HasCooldown = false
local CURRENT_IBAN = nil

-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

RegisterNetEvent("tpz_banking:client:refresh")
AddEventHandler("tpz_banking:client:refresh", function(iban, data, updateType)

    local PlayerData = GetPlayerData()

    if not PlayerData.IsBusy then 
        return 
    end

    data.cash = data.accounts['cash']
    data.gold = data.accounts['gold']

    data.cash = Round(data.cash, 4)

    SendNUIMessage({ 
        action = 'loadBankingInformation',
        client_det = data,
    })

end)

RegisterNetEvent("tpz_banking:client:sendNotification")
AddEventHandler("tpz_banking:client:sendNotification", function(message, actionType)
    SendNotification(message, actionType)
end)

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

GetCurrentIBAN = function()
    return CURRENT_IBAN
end

SetCurrentIBAN = function(iban)
    CURRENT_IBAN = iban
end

SendNotification = function(message, notificationType)

    local PlayerData = GetPlayerData()

    if PlayerData.IsBusy then
		local notify_color = Config.NotificationColors[notificationType]
		SendNUIMessage({ action = 'sendNotification', notification_data = {message = message, type = notificationType, color = notify_color} })
	end

end

OpenBankingNUI = function(bankName)

    local PlayerData = GetPlayerData()

    if PlayerData.IsBusy then 
        return 
    end

    PlayerData.IsBusy = true

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_banking:callbacks:getBankingInformation", function(res)

        if res == nil then
            res = false -- Required for JS, it will return undefined if not.
        end

        TaskStandStill(PlayerPedId(), -1)
    
        if res then

            CURRENT_IBAN = res.iban

            res.cash = res.accounts['cash']
            res.gold = res.accounts['gold']

            res.cash = Round(res.cash, 4)

            SendNUIMessage({ 
                action = 'loadBankingInformation',
                client_det = res,
            })

        end
    
        Wait(250)
        ToggleNUI(true, res)

    end, { iban = nil })
end

ToggleNUI = function(display, hasAccount)
    local PlayerData = GetPlayerData()

	SetNuiFocus(display,display)

	PlayerData.IsBusy = display

    if not display then
        ClearPedTasks(PlayerPedId())

        CurrentTransactionRecords = 4
        DisplayRadar(true)

        CURRENT_IBAN = nil
    end

    SendNUIMessage({ 
        action             = 'toggle', 
        toggle             = display, 

        has_account        = hasAccount,
        account_cost       = Config.BankRegistryCost.Cost,

        transfer_transaction_fees = Config.TransferTransactionFees,
    })
end

CloseNUI = function()
    local PlayerData = GetPlayerData()
    if PlayerData.IsBusy then SendNUIMessage({action = 'close'}) end
end

---------------------------------------------------------------
--[[ NUI Callbacks ]]--
---------------------------------------------------------------

RegisterNUICallback('register', function(data)

    if HasCooldown then
        return
    end 

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_banking:callbacks:registered", function(res)

        if res == false then
            HasCooldown = false
            return
        end

        CURRENT_IBAN = res.iban

        local data = { iban = res.iban, gold = 0, cash = 0 }

        SendNUIMessage({ 
            action = 'loadBankingInformation',
            client_det = data,
        })

        SendNUIMessage({ action = 'registeredAccount' })

    end)

end)

RegisterNUICallback('close', function()
	ToggleNUI(false)
end)

---------------------------------------------------------------
--[[ Functions ]]--
---------------------------------------------------------------

Citizen.CreateThread(function()

    while true do
        Citizen.Wait(0)

        if GetPlayerData().IsBusy then
            DisplayRadar(false)
        else
            Wait(1000)
        end

    end

end)