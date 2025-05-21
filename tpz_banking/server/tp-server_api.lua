
-- local BankAPI = exports.tpz_banking:getAPI()

-----------------------------------------------------------
--[[ Exports ]]--
-----------------------------------------------------------

exports('getAPI', function()

  local self = {}

  -- returns main account iban (string).
  self.getIBANBySource = function(source)
    return GetIBANBySource(targetSource)
  end

  -- returns main account iban (string).
  self.getIBANByCharIdentifier = function(charIdentifier)
    return GetIBANByCharIdentifier(charIdentifier)
  end

  -- returns current money type (amount) from an account IBAN (integer).
  -- @param iban    : The IBAN from a Banking Account.
  -- @param account : "cash", "gold"
  self.getAccountMoney = function(iban, account)
    return GetAccountMoney(iban, account)
  end

  -- @param iban            : The IBAN from a Banking Account.
  -- @param reason          : The transaction reason in-short (TRANSFERRED, DEPOSITED, WITHDRAWN, PAID, ETC.)
  -- @param transactionType : "DEPOSIT", "WITHDRAW".
  -- @param account         : "cash", "gold"
  -- @param amount          : The input amount to deposit or withdraw.
  self.executeTransactionType = function(iban, transactionType, account, amount)

    if transactionType == 'DEPOSIT' then
      DepositAccount(iban, reason, account, amount)

    elseif transactionType == 'WITHDRAW' then
      WithdrawFromAccount(iban, reason, account, amount)
    end

  end

  -- returns all available bank accounts on a table form.
  self.getBankAccounts = function()
    return GetAccounts()
  end

end)