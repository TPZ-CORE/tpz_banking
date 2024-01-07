

local HasCooldown     = false

local CurrentTransactionRecords = 4

-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

RegisterNetEvent("tpz_banking:refreshPlayerBankInformation")
AddEventHandler("tpz_banking:refreshPlayerBankInformation", function()
    if not ClientData.HasBankOpen then 
        return 
    end

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_banking:getBankingInformation", function(cb)
        SendNUIMessage({ action = 'loadBankingInformation', client_det = cb })
    end, { bank = ClientData.CurrentBankName })
end)

RegisterNetEvent("tpz_banking:refreshPlayerBills")
AddEventHandler("tpz_banking:refreshPlayerBills", function()
    RequestBills()
end)

RegisterNetEvent("tpz_banking:sendNotification")
AddEventHandler("tpz_banking:sendNotification", function(message, type)
    SendNotification(message, type)
end)

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

RequestBills = function ()
    SendNUIMessage({ action = 'clearBills' } )

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_society:getBills", function(result)

        local length = GetTableLength(result)

        if length > 0 then

            for index, bill in pairs (result) do
                SendNUIMessage({ action = 'loadBill', result = bill } )
            end
        end

    end)
end

RequestTransactionRecords = function ()

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_banking:getBankingRecords", function(result)

        if not result then
            return
        end

        local elements     = {}

        for index, record in pairs (result) do
            -- Loading History Record only based on the opened Bank Account.
            if record.bank == ClientData.CurrentBankName then
                table.insert(elements, record)
            end
        end

        local currentElements = #elements

        if currentElements >= 5 then
            currentElements = 4
        end

        for record in IterateLastEntries(elements, currentElements - 1) do
            SendNUIMessage({ action = 'loadHistoryRecord', result = record } )
        end
          
    end)
end

SendNotification = function(message, type)

    if ClientData.HasBankOpen then
		local notify_color = Config.NotificationColors[type]
		SendNUIMessage({ action = 'sendNotification', notification_data = {message = message, type = type, color = notify_color} })
	end

end

function IterateRange (Table, Min, Max)
  
    local ClosureIndex = Min - 1
    local ClosureMax   = math.min(Max, #Table)
    
    local function Closure ()
      if (ClosureIndex < ClosureMax) then
        ClosureIndex = ClosureIndex + 1
        return Table[ClosureIndex]
      end
    end
  
    return Closure
end

function IterateLastEntries (Table, Count)
    local TableSize  = #Table
    local StartIndex = (TableSize - Count)
    return IterateRange(Table, StartIndex, TableSize)
end
  
  

-----------------------------------------------------------
--[[ Bill Requests & Payments  ]]--
-----------------------------------------------------------

RegisterNUICallback('requestBills', function()
    RequestBills()
end)

RegisterNUICallback('payBill', function(data)
    if HasCooldown then
        return
    end 

    HasCooldown = true

    TriggerServerEvent('tpz_society:payBill', tonumber(data.billingId), ClientData.CurrentBankName)
    Wait(2000)
    HasCooldown = false
end)

-----------------------------------------------------------
--[[ Transaction Records  ]]--
-----------------------------------------------------------

RegisterNUICallback('requestTransactionRecords', function()
    RequestTransactionRecords()
end)

-----------------------------------------------------------
--[[ Withdrawals, Deposits & Transfers ]]--
-----------------------------------------------------------

RegisterNUICallback('requestAccountDeposit', function(data)

    if HasCooldown then
        return
    end 

    if tonumber(data.amount) == nil or ( data.amount and tonumber(data.amount) <= 0 ) then
        SendNotification(Locales['INVALID_AMOUNT'], 'error')
        return
    end

    HasCooldown = true

    TriggerServerEvent("tpz_banking:depositAccountMoney", tonumber(data.account), tonumber(data.amount), ClientData.CurrentBankName)

    Wait(3000)
    HasCooldown = false
end)

RegisterNUICallback('requestAccountWithdrawal', function(data)
    if HasCooldown then
        return
    end 

    if tonumber(data.amount) == nil or ( data.amount and tonumber(data.amount) <= 0 ) then
        SendNotification(Locales['INVALID_AMOUNT'], 'error')
        return
    end

    HasCooldown = true

    TriggerServerEvent("tpz_banking:withdrawAccountMoney", tonumber(data.account), tonumber(data.amount), ClientData.CurrentBankName)

    Wait(3000)
    HasCooldown = false
end)

RegisterNUICallback('requestAccountTransfer', function(data)
    if HasCooldown then
        return
    end 

    if tonumber(data.iban) == nil then
        SendNotification(Locales['INVALID_IBAN'], 'error')
        return
    end

    if tonumber(data.amount) == nil or ( data.amount and tonumber(data.amount) <= 0 ) then
        SendNotification(Locales['INVALID_AMOUNT'], 'error')
        return
    end

    HasCooldown = true
    TriggerServerEvent('tpz_banking:transferMoneyAccount', tonumber(data.iban), tonumber(data.account), tonumber(data.amount), ClientData.CurrentBankName, tonumber(data.currentIban))

    Wait(3000)
    HasCooldown = false
end)

RegisterNUICallback('close', function()
	ToggleNUI(false)
end)

---------------------------------------------------------------
-- Functions
---------------------------------------------------------------

OpenBankingNUI = function(bankName)

    if ClientData.HasBankOpen then 
        return 
    end

    ClientData.HasBankOpen     = true
    ClientData.CurrentBankName = bankName

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_banking:getBankingInformation", function(res)

        if not res then
            -- not account

            local inputData = {
                title = string.format(Locales['BANKING_REGISTRY_TITLE'], Config.BankRegistryCost),
                desc  = Locales['BANKING_REGISTRY_DESCRIPTION'],
                buttonparam1 = Locales['BANKING_REGISTRY_ACCEPT_BUTTON'],
                buttonparam2 = Locales['BANKING_REGISTRY_DECLINE_BUTTON']
            }
                                        
            TriggerEvent("tp_inputs:getButtonInput", inputData, function(cb)
            
                if cb == "ACCEPT" then
                    TriggerServerEvent('tpz_banking:registerBankAccount', ClientData.CurrentBankName)
                end

                Wait(2000)
                ClientData.HasBankOpen = false
            end) 

            return
        end

        TaskStandStill(PlayerPedId(), -1)
    
        ExecuteCommand("hud:hideall")
    
        SendNUIMessage({ 
            action = 'loadBankingInformation',
            client_det = res,
        })
    
        Wait(250)
        ToggleNUI(true)

    end, { bank = bankName } )
end

ToggleNUI = function(display)
	SetNuiFocus(display,display)

	ClientData.HasBankOpen = display

    if not display then
        ClearPedTasks(PlayerPedId())
        ExecuteCommand("hud:hideall")

        CurrentTransactionRecords = 4
    end

    SendNUIMessage({ action = 'toggle', toggle = display })
end

CloseNUI = function()
    if ClientData.HasBankOpen then SendNUIMessage({action = 'close'}) end
end