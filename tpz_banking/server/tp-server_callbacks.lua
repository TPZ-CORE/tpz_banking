
-----------------------------------------------------------
--[[ Callbacks  ]]--
-----------------------------------------------------------

-- @parameter bank : Required parameter for the following callback to check if Banking Data is null or exists.
exports.tpz_core:rServerAPI().addNewCallBack("tpz_banking:getBankingInformation", function(source, cb, data)
	local _source = source

	if Banking[_source] == nil or Banking[_source][data.bank] == nil then
		cb(false)
	else
		cb(Banking[_source][data.bank])
	end
end)

exports.tpz_core:rServerAPI().addNewCallBack("tpz_banking:getBankingRecords", function(source, cb)
	local _source = source

	if BankingRecords[_source] == nil then
		cb(false)
	else
		cb(BankingRecords[_source])
	end
end)