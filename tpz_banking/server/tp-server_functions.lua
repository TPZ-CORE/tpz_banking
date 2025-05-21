local TPZ = exports.tpz_core:getCoreAPI()

-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

local function GetPlayerBankAccount(targetSource, charIdentifier)

    local Accounts = GetAccounts()

    for index, account in pairs (Accounts) do
  
      if ( targetSource and tonumber(account.source) == tonumber(targetSource) ) or ( charIdentifier and tonumber(account.charidentifier) == tonumber(charIdentifier) ) then
        return account.iban
      end
  
    end
  
    return nil
  
end
  
-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

-- returns main account iban (string).
function GetIBANBySource(targetSource)
    return GetPlayerBankAccount(targetSource)
end

-- returns main account iban (string).
function getIBANByCharIdentifier(charIdentifier)
	return GetPlayerBankAccount(nil, charIdentifier)
end

-- returns current money type (amount) from an account IBAN (integer).
-- @param iban    : The IBAN from a Banking Account.
-- @param account : "cash", "gold"
function GetAccountMoney(iban, account)
    local Accounts = GetAccounts()

    iban           = tostring(iban)

    if Accounts[iban] == nil then
      print(string.format('%s IBAN does not exist, API getAccountMoney function was executed.', iban))
      return 0
    end
    
    account = string.lower(account)

    if account ~= 'cash' and account ~= 'gold' then
      return 0
    end

    -- string.lower : accepts only lowercase cash and gold parameters (We force it)
    return Accounts[iban].accounts[string.lower(account)]

end

-- @param iban            : The IBAN from a Banking Account.
-- @param account         : "cash", "gold"
-- @param amount          : The input amount to deposit.
function DepositAccount(iban, reason, account, amount)

    local Accounts  = GetAccounts()

    iban            = tostring(iban)
    account         = string.lower(account)

    if (Accounts[iban] == nil) or (account ~= 'cash' and account ~= 'gold') then
       print(string.format('%s IBAN does not exist or the transaction account type (%s) does not exist, API executeTransactionType function was executed.', iban, account))

    else
        Accounts[iban].accounts[account] = Accounts[iban].accounts[account] + amount

        local webhookData = Config.DiscordWebhooking

        if webhookData.Enabled then
    
            local title      = string.format("🏦` Bank Transaction | IBAN: %s`", iban)
            local message    = string.format("There was a transaction on the mentioned IBAN account.\n\n**Reason:** `%s`\n**Account:** `%s`\n**Amount:** `%s`", reason, string.upper(account), amount)
            
            TPZ.SendToDiscord(webhookData.Url, title, message, webhookData.Color)
        end
    end

end

-- @param iban            : The IBAN from a Banking Account.
-- @param reason          : The transaction reason in-short (TRANSFERRED, DEPOSITED, WITHDRAWN, PAID, ETC.)
-- @param account         : "cash", "gold"
-- @param amount          : The input amount to withdraw.
function WithdrawFromAccount(iban, reason, account, amount)

    local Accounts  = GetAccounts()

    iban            = tostring(iban)
    account         = string.lower(account)

    if (Accounts[iban] == nil) or (account ~= 'cash' and account ~= 'gold') then
       print(string.format('%s IBAN does not exist or the transaction account type (%s) does not exist, API executeTransactionType function was executed.', iban, account))

    else
        Accounts[iban].accounts[account] = Accounts[iban].accounts[account] - amount

        if Accounts[iban].accounts[account] <= 0 then -- We prevent negative values.
          Accounts[iban].accounts[account] = 0
        end

        local webhookData = Config.DiscordWebhooking

        if webhookData.Enabled then
    
            local title      = string.format("🏦` Bank Transaction | IBAN: %s`", iban)
            local message    = string.format("There was a transaction on the mentioned IBAN account.\n\n**Reason:** `%s`\n**Account:** `%s`\n**Amount:** `%s`", reason, string.upper(account), amount)
            
            TPZ.SendToDiscord(webhookData.Url, title, message, webhookData.Color)
        end

    end

end

function Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function GetTableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end
