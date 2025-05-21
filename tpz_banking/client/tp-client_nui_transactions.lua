

local HasCooldown = false

-----------------------------------------------------------
--[[ NUI Callbacks  ]]--
-----------------------------------------------------------

RegisterNUICallback('executeTransactionType', function(data)

    if HasCooldown then
        return
    end 

    if tonumber(data.amount) == nil or ( data.amount and tonumber(data.amount) <= 0 ) then
        SendNotification(Locales['INVALID_AMOUNT'], 'error')
        return
    end

    if tonumber(data.account) == 0 then
        data.account = 'CASH'

    elseif tonumber(data.account) == 1 then
        data.account = 'GOLD'
    end

    TriggerServerEvent('tpz_banking:server:executeTransactionType', tostring(data.iban), data.type, data.account, tonumber(data.amount), tostring(data.to_iban))

    HasCooldown = true

    Wait(1000)
    HasCooldown = false
end)
