

local TPZ    = {}

TriggerEvent("getTPZCore", function(cb) TPZ = cb end)

-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

-- The following event is triggered from `tpz_society` which is for creating history records
-- when a bill is paid.
RegisterServerEvent('tpz_banking:addHistoryRecord')
AddEventHandler('tpz_banking:addHistoryRecord', function(bankName, identifier, charidentifier, username, reason, cost, account )
  local _source = source
  
  local Parameters = { 
    ['bank']           = bankName, 
    ['identifier']     = identifier, 
    ['charidentifier'] = charidentifier,
    ['username']       = username, 
    ['reason']         = reason,
    ['cost']           = cost,
    ['account']        = account,
  }
  exports.ghmattimysql:execute("INSERT INTO banking_records ( `bank`,`identifier`,`charidentifier`,`username`,`reason`, `cost`, `account`) VALUES ( @bank, @identifier, @charidentifier, @username, @reason, @cost, @account)", Parameters)

  TriggerClientEvent("tpz_banking:refreshPlayerBills", _source)
end)

