local TPZ = exports.tpz_core:getCoreAPI()

-----------------------------------------------------------
--[[ General Events ]]--
-----------------------------------------------------------

-- @param targetIban : This is valid only for "TRANSFER" transaction type.
RegisterServerEvent('tpz_banking:server:executeTransactionType')
AddEventHandler('tpz_banking:server:executeTransactionType', function(iban, transactionType, account, amount, targetIban)
  local _source   = source
  local xPlayer   = TPZ.GetPlayer(_source)

  local Accounts  = GetAccounts()

  transactionType = string.upper(transactionType)
  account         = string.lower(account)

  if (Accounts[iban] == nil) or (account ~= 'cash' and account ~= 'gold') then
    print(string.format('%s IBAN does not exist or the transaction account type (%s) does not exist, executeTransactionType event was executed.', iban, account))
    return
  end

  if transactionType == 'DEPOSIT' then
    
    -- We are checking if player has enough money to deposit.
    local currentMoney = xPlayer.getAccount(0)

    if account == 'gold' then
      currentMoney = xPlayer.getAccount(1)
    end

    if currentMoney < amount then
      TriggerClientEvent("tpz_banking:client:sendNotification", _source, Locales[string.upper(account)]['NOT_ENOUGH_DEPOSIT'], 'error')
      return
    end

    if amount < Config.TransactionLimitations.Deposit[string.upper(account)] then
      TriggerClientEvent("tpz_banking:client:sendNotification", _source, string.format(Locales[string.upper(account)]['NOT_REACHING_MIN_ENOUGH'], Config.TransactionLimitations.Deposit[string.upper(account)]), 'error')
      return
    end

    DepositAccount(iban, Locales['DEPOSITED'], account, amount)

    if account == 'cash' then
      xPlayer.removeAccount(0, amount)

    elseif account == 'gold' then
      xPlayer.removeAccount(1, amount)
    end

    TriggerClientEvent("tpz_banking:client:sendNotification", _source, string.format(Locales[string.upper(account)]['DEPOSITED'], amount), 'success')

  elseif transactionType == 'WITHDRAW' then

    -- We are checking if player has enough money on the bank account to withdraw.
    if Accounts[iban].accounts[account] < amount then
      TriggerClientEvent("tpz_banking:client:sendNotification", _source, Locales[string.upper(account)]['NOT_ENOUGH_WITHDRAW'], 'error')
      return
    end
  
    WithdrawFromAccount(iban, Locales['WITHDRAWN'], account, amount)

    if account == 'cash' then
      xPlayer.addAccount(0, amount)
      
    elseif account == 'gold' then
      xPlayer.addAccount(1, amount)
    end

    TriggerClientEvent("tpz_banking:client:sendNotification", _source, string.format(Locales[string.upper(account)]['WITHDRAWN'], amount), 'success')

  elseif transactionType == 'TRANSFER' then

    if not Config.Options['TRANSFERS'] then
      TriggerClientEvent("tpz_banking:client:sendNotification", _source, Locales['BANK_TRANSFERS_DISABLED'], 'error')
      return
    end

    if Accounts[tostring(targetIban)] == nil then
      TriggerClientEvent("tpz_banking:client:sendNotification", _source, Locales['IBAN_DOES_NOT_EXIST'], 'error')
      return
    end
    
    if tostring(iban) == tostring(targetIban) then
      TriggerClientEvent("tpz_banking:client:sendNotification", _source, Locales['INTRA_ACCOUNT_REJECT'], 'error')
      return
    end

    if Accounts[iban].accounts['cash'] < amount then
      TriggerClientEvent("tpz_banking:client:sendNotification", _source, Locales['NOT_ENOUGH_TRANSFER'], 'error')
      return
    end

    if amount < Config.TransactionLimitations.Transfer then
      TriggerClientEvent("tpz_banking:client:sendNotification", _source, string.format(Locales['NOT_MIN_ENOUGH_TO_TRANSFER'], Config.TransactionLimitations.Transfer), 'error')
      return
    end

    local newAmount = amount

    if Config.TransferTransactionFees > 0 then
      newAmount       = amount - (amount * Config.TransferTransactionFees) / 100

      newAmount       = Round(newAmount, 1)
      newAmount       = math.floor(newAmount)
    end

    WithdrawFromAccount(iban, Locales['TRANSFERRED'], account, amount)
    DepositAccount(targetIban, Locales['TRANSFERRED_RECEIVER'], account, newAmount)

    TriggerClientEvent("tpz_banking:client:sendNotification", _source, string.format(Locales['TRANSFERRED_TO'], newAmount, targetIban), 'success')

    -- We check if a player has the Bank Account (of the target) active to update the money account.
    if Accounts[targetIban].source and Accounts[targetIban].source ~= 0 then
      TriggerClientEvent("tpz_banking:client:refresh", tonumber(Accounts[targetIban].source), targetIban, Accounts[targetIban] )
    end

  end

  Wait(500)

  TriggerClientEvent("tpz_banking:client:refresh", _source, iban, Accounts[iban] )
end)
