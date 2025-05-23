local TPZ           = exports.tpz_core:getCoreAPI()
local Accounts      = {}
local LoadedResults = false

-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

-- Load user bank accounts through the database first.
local function LoadAccounts()

  exports["ghmattimysql"]:execute("SELECT * FROM `bank_accounts`", {}, function(result)

    local tableLength = GetTableLength(result)

    if tableLength > 0 then

      for _, res in pairs (result) do 

        local uniqueId = res.identifier .. "_" .. res.charidentifier
        local accounts = json.decode(res.accounts)

        local data = {
          iban                = tostring(res.iban),
          identifier          = res.identifier,
          charidentifier      = res.charidentifier,
          accounts            = { ['cash'] = tonumber(accounts['cash']), ['gold'] = tonumber(accounts['gold']) },
          source              = nil,
        }

        Accounts[res.iban] = data -- inserting all new player data.

      end

      if Config.Debug then
        print(string.format('Successfully loaded %s bank accounts.', tableLength))
      end
    
    end

  end)

end

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

function GetAccounts()
  return Accounts
end

-----------------------------------------------------------
--[[ Base Events ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
    return
  end

  LoadAccounts()
  LoadedResults = true
end)

-- We clear all data on resource stop.
AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
    return
  end

  Accounts = nil
end)


AddEventHandler('playerDropped', function (reason)
  local _source = source

  for index, account in pairs (Accounts) do

    -- In case the account source is the owner who dropped, we set the source as null.
    -- We also save the main bank accounts.
    if tonumber(account.source) == tonumber(_source) then
      account.source = nil

      local Parameters = { 
        ['iban']      = account.iban,
        ['accounts']  = json.encode({ ['cash'] = account.accounts['cash'], ['gold'] = account.accounts['gold'] }),
      }
      
      exports.ghmattimysql:execute("UPDATE `bank_accounts` SET `accounts` = @accounts WHERE `iban` = @iban", Parameters)
    end


  end

end)

-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

RegisterServerEvent('tpz_banking:server:isPlayerReady')
AddEventHandler('tpz_banking:server:isPlayerReady', function()
  local _source = source

  while not LoadedResults do
    Wait(500)
  end

  local xPlayer = TPZ.GetPlayer(_source)

  if not xPlayer.loaded() then
    return
  end

  local charIdentifier = xPlayer.getCharacterIdentifier()

  for index, account in pairs (Accounts) do

    -- In case the account source is the owner who selected a character, we set update the source.
    if tonumber(account.charidentifier) == tonumber(charIdentifier) then
      account.source = _source
    end

  end

end)

-----------------------------------------------------------
--[[ Threads ]]--
-----------------------------------------------------------

local CurrentTime = 0

Citizen.CreateThread(function()
	while true do
		Wait(60000)

    local time        = os.date("*t") 
    local currentTime = table.concat({time.hour, time.min}, ":")

    local finished    = false
    local shouldSave  = false

    for index, restartHour in pairs (Config.RestartHours) do

      if currentTime == restartHour then
        shouldSave = true
      end

      if next(Config.RestartHours, index) == nil then
        finished = true
      end

    end

    while not finished do
      Wait(1000)
    end

    CurrentTime = CurrentTime + 1

    if Config.SaveDataRepeatingTimer.Enabled and CurrentTime == Config.SaveDataRepeatingTimer.Duration then
      CurrentTime = 0
      shouldSave  = true
    end

    if shouldSave then

      for index, account in pairs (Accounts) do

          local Parameters = { 
            ['iban']      = account.iban,
            ['accounts']  = json.encode({ ['cash'] = account.accounts['cash'], ['gold'] = account.accounts['gold'] }),
          }
          
          exports.ghmattimysql:execute("UPDATE `bank_accounts` SET `accounts` = @accounts WHERE `iban` = @iban", Parameters)
    
      end

    end

  end

end)

