

local TPZ    = {}

TriggerEvent("getTPZCore", function(cb) TPZ = cb end)

Banking        = {}
BankingRecords = {}

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

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


function LoadHistoryRecords(source, charidentifier)
  local _source = source

  BankingRecords[_source] = {}

  exports["ghmattimysql"]:execute("SELECT * FROM banking_records ORDER BY id", {}, function(result)

    local tableLength = GetTableLength(result)

    if tableLength > 0 then

      for _, res in pairs (result) do 

        if res.charidentifier == charidentifier then

          table.insert(BankingRecords[_source], res)

        end

      end

    end

  end)
  
end

function LoadBankingAccounts(source, charidentifier)
  local _source = source

  Banking[_source] = {}
  
  exports["ghmattimysql"]:execute("SELECT * FROM banking", {}, function(result)

    local tableLength = GetTableLength(result)
    local finished    = false

    if tableLength > 0 then

      for _, res in pairs (result) do 

        if res.charidentifier == charidentifier then

          Banking[_source][res.bank] = {}
          Banking[_source][res.bank] = res

        end

        if next(result, _) == nil then
          finished = true
        end

      end
      
    else
      finished = true
    end

    while not finished do
      Wait(1000)
    end

    TriggerClientEvent("tpz_banking:setPlayerAsLoaded", _source)

  end)

end

RegisterHistoryRecord = function(source, bankName, identifier, charidentifier, reason, account, cost)
  local _source = source

  local currentDate = os.date('%d').. '/' ..os.date('%m').. '/' .. Config.Year .. " " .. os.date('%H') .. ":" .. os.date('%M') .. ":" .. os.date('%S')

  local Parameters = { 
    ['bank']            = bankName,
    ['identifier']      = identifier,
    ['charidentifier']  = charidentifier,
    ['reason']          = reason,
    ['account']         = account,
    ['cost']            = cost,
    ['date']            = currentDate,
  }


  table.insert(BankingRecords[_source], {bank = bankName, identifier = identifier, charidentifier = charidentifier, reason = reason, account = account, cost = cost, date = currentDate})

  exports.ghmattimysql:execute("INSERT INTO banking_records ( `bank`, `identifier`,`charidentifier`, `reason`, `account`,`cost`, `date`) VALUES ( @bank, @identifier, @charidentifier, @reason, @account, @cost, @date)", Parameters)

end

-----------------------------------------------------------
--[[ Base Events ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    Banking = nil
    BankingRecords = nil
end)

-- When player quits the game, we save the player data
AddEventHandler('playerDropped', function (reason)
  local _source = source

  BankingRecords[_source] = nil

  if Banking[_source] == nil then
    return
  end

  local bankingData = Banking[_source]

  for index, res in pairs (bankingData) do

    local Parameters = { 
      ['charidentifier'] = res.charidentifier,
      ['bank']           = res.bank,
      ['money']          = res.money,
      ['gold']           = res.gold
    }
  
    exports.ghmattimysql:execute("UPDATE banking SET money = @money, gold = @gold WHERE charidentifier = @charidentifier AND bank = @bank"
      , Parameters)

  end

end)

RegisterServerEvent('tpz_banking:requestBankingInformation')
AddEventHandler('tpz_banking:requestBankingInformation', function()
  local _source         = source
  local xPlayer         = TPZ.GetPlayer(_source)

  while not xPlayer.loaded() do
    Wait(1000)
  end

	local charidentifier  = xPlayer.getCharacterIdentifier()

  LoadHistoryRecords(_source, charidentifier)
  LoadBankingAccounts(_source, charidentifier)
end)

-----------------------------------------------------------
--[[ Events - Bank Registry ]]--
-----------------------------------------------------------

-- The following event is triggered when player has not been registered to the following and called
-- bank and pays and amount to register and load the new bank account to the Banking data.
RegisterServerEvent('tpz_banking:registerBankAccount')
AddEventHandler('tpz_banking:registerBankAccount', function(bankName)
  local _source         = source

  local xPlayer         = TPZ.GetPlayer(_source)
  local identifier      = xPlayer.getIdentifier()
	local charidentifier  = xPlayer.getCharacterIdentifier()
  local username        = xPlayer.getFirstName() .. ' ' .. xPlayer.getLastName()

  local money = xPlayer.getAccount(0)

  if money < Config.BankRegistryCost then
    -- notification of banking
    return
  end

  xPlayer.removeAccount(0, Config.BankRegistryCost)

  -- paid notify and registry

  if Banking[_source] == nil then
    Banking[_source] = {}
  end

  Banking[_source][bankName] = {}

  Banking[_source][bankName].bank           = bankName
  Banking[_source][bankName].name           = GetPlayerName(_source)
  Banking[_source][bankName].identifier     = identifier
  Banking[_source][bankName].charidentifier = charidentifier
  Banking[_source][bankName].username       = username
  Banking[_source][bankName].money          = 0
  Banking[_source][bankName].gold           = 0

  local Parameters = { 
    ['bank']            = bankName,
    ['name']            = GetPlayerName(_source),
    ['identifier']      = identifier,
    ['charidentifier']  = charidentifier,
    ['username']        = username,
    ['money']           = 0,
    ['gold']            = 0
  }
  exports.ghmattimysql:execute("INSERT INTO banking ( `bank`, `name`,`identifier`,`charidentifier`, `username`, `money`,`gold`) VALUES ( @bank, @name, @identifier, @charidentifier, @username, @money, @gold)", Parameters)


end)

-----------------------------------------------------------
--[[ Events - Banking Deposits (Other Scripts) ]]--
-----------------------------------------------------------

RegisterServerEvent('tpz_banking:depositDefaultBankingAccount')
AddEventHandler('tpz_banking:depositDefaultBankingAccount', function(targetId, amount, reason)
  local _tsource = targetId

  local defaultBankName = Config.DefaultBankSalaryReceive

  local bankData = Banking[_tsource][Config.DefaultBankSalaryReceive]

  if bankData == nil then
    -- Player not registered to the default bank which supports society salaries or any other reasons.
    return
  end

  Banking[_tsource][defaultBankName].money = Banking[_tsource][defaultBankName].money + amount

  RegisterHistoryRecord(_tsource, Config.DefaultBankSalaryReceive, bankData.identifier, bankData.charidentifier, reason, 0, amount)
end)

-----------------------------------------------------------
--[[ Events - Deposit, Withdraw & Transfers ]]--
-----------------------------------------------------------

RegisterServerEvent('tpz_banking:depositAccountMoney')
AddEventHandler('tpz_banking:depositAccountMoney', function(account, amount, bankName)
  local _source = source
  local xPlayer = TPZ.GetPlayer(_source)
  local steamName = GetPlayerName(_source)

  local money   = xPlayer.getAccount(account)

  if money < amount then
    TriggerClientEvent("tpz_banking:sendNotification", _source, Locales[account]['NOT_ENOUGH_DEPOSIT'], 'error')
    return
  end

  xPlayer.removeAccount(account, amount)

  if account == 0 then
    Banking[_source][bankName].money = Banking[_source][bankName].money + amount

  elseif account == 3 then
    Banking[_source][bankName].gold = Banking[_source][bankName].gold + amount
  end

  local bankData = Banking[_source][bankName]

  -- webhook
  TriggerClientEvent("tpz_banking:refreshPlayerBankInformation", _source)

  TriggerClientEvent("tpz_banking:sendNotification", _source, string.format(Locales[account]['DEPOSITED'], amount), 'success')

  RegisterHistoryRecord(_source, bankName, bankData.identifier, bankData.charidentifier, Locales['DEPOSITED'], account, amount)

  local webhookData     = Config.Webhooking

  if webhookData.Enabled then
    local message         = "**Steam name: **`" .. steamName .. "`**\nIdentifier: **`" .. bankData.identifier .. " (Char: " .. bankData.charidentifier .. ") `"
  
    local title = "🏦` The following player deposited " .. amount .. " " .. Locales[account]['CURRENCY'] .. " to his bank account.`"
    TriggerEvent("tpz_core:sendToDiscord", webhookData.Url, title, message, webhookData.Color)
  end

end)

RegisterServerEvent('tpz_banking:withdrawAccountMoney')
AddEventHandler('tpz_banking:withdrawAccountMoney', function(account, amount, bankName)
  local _source = source
  local xPlayer = TPZ.GetPlayer(_source)
  local steamName = GetPlayerName(_source)

  local money   = Banking[_source][bankName].money

  if account == 3 then
    money = Banking[_source][bankName].gold
  end

  if money < amount then
    TriggerClientEvent("tpz_banking:sendNotification", _source, Locales[account]['NOT_ENOUGH_WITHDRAW'], 'error')
    return
  end

  xPlayer.addAccount(account, amount)

  if account == 0 then
    Banking[_source][bankName].money = Banking[_source][bankName].money - amount

  elseif account == 3 then
    Banking[_source][bankName].gold = Banking[_source][bankName].gold - amount
  end

  local bankData = Banking[_source][bankName]


  TriggerClientEvent("tpz_banking:refreshPlayerBankInformation", _source)
  TriggerClientEvent("tpz_banking:sendNotification", _source, string.format(Locales[account]['WITHDREW'], amount), 'success')

  RegisterHistoryRecord(_source, bankName, bankData.identifier, bankData.charidentifier, Locales['WITHDRAWAL'], account, amount)

  local webhookData     = Config.Webhooking

  if webhookData.Enabled then
    local message         = "**Steam name: **`" .. steamName .. "`**\nIdentifier: **`" .. bankData.identifier .. " (Char: " .. bankData.charidentifier .. ") `"
  
    local title = "🏦` The following player withdrew " .. amount .. " " .. Locales[account]['CURRENCY'] .. " from his bank account.`"
    TriggerEvent("tpz_core:sendToDiscord", webhookData.Url, title, message, webhookData.Color)
  end

end)


RegisterServerEvent('tpz_banking:transferMoneyAccount')
AddEventHandler('tpz_banking:transferMoneyAccount', function(iban, account, amount, bankName, currentIban)
  local _source = source
  local steamName = GetPlayerName(_source)

  local money   = Banking[_source][bankName].money

  if money < amount then
    TriggerClientEvent("tpz_banking:sendNotification", _source, Locales[account]['NOT_ENOUGH_TRANSFER'], 'error')
    return
  end

  if iban == currentIban then
    TriggerClientEvent("tpz_banking:sendNotification", _source, Locales['SAME_IBAN'], 'error')
    return
  end

  if amount < Config.BankTransfersVAT.MinimumAmount then
    TriggerClientEvent("tpz_banking:sendNotification", _source, string.format(Locales['NOT_MIN_ENOUGH_TO_TRANSFER'], Config.BankTransfersVAT.MinimumAmount), 'error')
    return
  end

  local doesBankExist = false
  local newAmount     = amount

  if Config.BankTransfersVAT.VAT > 0 then
    newAmount = amount - (amount * Config.BankTransfersVAT.VAT) / 100

    newAmount = Round(newAmount, 1)
    newAmount = math.floor(newAmount)
  end

  exports["ghmattimysql"]:execute("SELECT * FROM banking WHERE id = @id", { ["@id"] = tonumber(iban) }, function(result)

    for index, bankAccount in pairs (Banking) do

      for index, bank in pairs (bankAccount) do

        if tonumber(bank.id) == tonumber(iban) then
          doesBankExist = true
    
          bank.money = bank.money + newAmount
        end

      end

    end
    
    if result[1] then
        
      if not doesBankExist then
        doesBankExist = true

        local Parameters = { ['id'] = tonumber(iban), ['money'] = newAmount }
        exports.ghmattimysql:execute("UPDATE banking SET money = money + @money WHERE id = @id", Parameters)

      end

    else
      TriggerClientEvent("tpz_banking:sendNotification", _source, Locales['IBAN_DOES_NOT_EXIST'], 'error')
    end

    if doesBankExist then

      Banking[_source][bankName].money = Banking[_source][bankName].money - amount
  
      TriggerClientEvent("tpz_banking:refreshPlayerBankInformation", _source)
      TriggerClientEvent("tpz_banking:sendNotification", _source, string.format(Locales[account]['TRANSFERRED'], amount, iban), 'success')
  
      local bankData = Banking[_source][bankName]

      RegisterHistoryRecord(_source, bankName, bankData.identifier, bankData.charidentifier, string.format(Locales['TRANSFERRED'], iban), account, amount)
    
      local webhookData     = Config.Webhooking

      if webhookData.Enabled then
        local message         = "**Steam name: **`" .. steamName .. "`**\nIdentifier: **`" .. bankData.identifier .. " (Char: " .. bankData.charidentifier .. ") `"
      
        local title = "🏦` The following player transferred " .. amount .. " " .. Locales[account]['CURRENCY'] .. " to another bank account with the following Iban. #" .. iban .. ".`"
        TriggerEvent("tpz_core:sendToDiscord", webhookData.Url, title, message, webhookData.Color)
      end
    
    end

  end)

end)

-----------------------------------------------------------
--[[ Events - History Records ]]--
-----------------------------------------------------------

RegisterServerEvent('tpz_banking:registerHistoryRecord')
AddEventHandler('tpz_banking:registerHistoryRecord', function(source, bankName, identifier, charidentifier, reason, account, cost)
  RegisterHistoryRecord(source, bankName, identifier, charidentifier, reason, account, cost)
end)
