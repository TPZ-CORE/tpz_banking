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

function Round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function GetTableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

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
--[[ Base Events ]]--
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
