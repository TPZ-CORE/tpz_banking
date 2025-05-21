local TPZ = exports.tpz_core:getCoreAPI()

-----------------------------------------------------------
--[[ Callbacks  ]]--
-----------------------------------------------------------

exports.tpz_core:getCoreAPI().addNewCallBack("tpz_banking:callbacks:getBankingInformation", function(source, cb, data)
	local _source         = source
	local xPlayer         = TPZ.GetPlayer(_source)
	
	local Accounts        = GetAccounts()

	local identifier     = xPlayer.getIdentifier()
	local charIdentifier = xPlayer.getCharacterIdentifier()

	local iban            = data.iban
	local accountData     = nil

	if not data.iban then
		iban = GetIBANBySource(_source)
	end

	if Accounts[iban] then
		accountData = Accounts[iban]

		accountData.isOwner = false
		
		if Accounts[iban].identifier == identifier and tonumber(Accounts[iban].charidentifier) == tonumber(charIdentifier) then
			accountData.isOwner = true
		end

	end

	-- If no account availabe, we return null.
	return cb(accountData)
end)


exports.tpz_core:getCoreAPI().addNewCallBack("tpz_banking:callbacks:registered", function(source, cb)
	local _source         = source
	local xPlayer         = TPZ.GetPlayer(_source)

	local Accounts        = GetAccounts()

	local identifier     = xPlayer.getIdentifier()
	local charIdentifier = xPlayer.getCharacterIdentifier()

	local money           = xPlayer.getAccount(0)

	if Config.BankRegistryCost.Account == 'GOLD' then
	  money = xPlayer.getAccount(1)
	end
  
	-- If not enough money, we notify the player.
	if money < Config.BankRegistryCost.Cost then
  
		TriggerClientEvent('tpz_banking:client:sendNotification', _source, Locales['NOT_ENOUGH_FOR_REGISTRATION'], "error")
		return cb(false)
	end
  
	if Config.BankRegistryCost.Account == 'CASH' then

		xPlayer.removeAccount(0, Config.BankRegistryCost.Cost)
  
	elseif Config.BankRegistryCost.Account == 'GOLD' then
		xPlayer.removeAccount(1, Config.BankRegistryCost.Cost)
	end
  
	local currentDate   = os.date('%d') .. os.date('%m') .. os.date('%H') .. os.date('%M') .. os.date('%S')
	local length        = GetTableLength(Accounts)
	local generatedIban = tostring(Config.FirstIBANLetters .. currentDate .. length)

	generatedIban       = string.upper(generatedIban)
  
	local data = {
	  iban                = generatedIban,
	  identifier          = identifier,
	  charidentifier      = charIdentifier,
	  accounts            = { ['cash'] = 0, ['gold'] = 0 },
	  source              = _source,
	}
  
	Accounts[generatedIban] = data -- inserting all new player data.
  
	local Parameters = { 
	  ['iban']            = generatedIban,
	  ['identifier']      = identifier,
	  ['charidentifier']  = charIdentifier,
	}
  
	exports.ghmattimysql:execute("INSERT INTO `bank_accounts` ( `iban`, `identifier`, `charidentifier`) VALUES ( @iban, @identifier, @charidentifier )", Parameters)
  
	TriggerClientEvent('tpz_banking:client:sendNotification', _source, Locales['SUCCESS_REGISTRATION'], "success")
  
	if Config.Debug then
	  print(string.format('The player with the online id: %s and steam name: %s has created a new bank account.', _source, GetPlayerName(_source) ))
	end

	return cb( { iban = generatedIban, identifier = identifier, charidentifier = charIdentifier })

end)

