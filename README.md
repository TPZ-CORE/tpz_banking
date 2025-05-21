# TPZ-CORE Banking

## Requirements

1. TPZ-Core: https://github.com/TPZ-CORE/tpz_core
2. TPZ-Characters: https://github.com/TPZ-CORE/tpz_characters
3. TPZ-Inventory : https://github.com/TPZ-CORE/tpz_inventory
4. TPZ-Notify: https://github.com/TPZ-CORE/tpz_notify
5. TPZ-Society : https://github.com/TPZ-CORE/tpz_society
   
# Installation

1. When opening the zip file, open `tpz_banking-main` directory folder and inside there will be another directory folder which is called as `tpz_banking`, this directory folder is the one that should be exported to your resources (The folder which contains `fxmanifest.lua`).

2. Add `ensure tpz_banking` after the **REQUIREMENTS** in the resources.cfg or server.cfg, depends where your scripts are located.

# Development API

## Exports

**Getter**
The specified export below is used on the `server` to use the API properly and faster.

```lua
local BankAPI = exports.tpz_banking:getAPI()
```

| Export                                                                    | Description                                                                                                                                                                                                                | Returned Type |
|---------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|
| `BankAPI.getIBANBySource(source)`               | Returns the player IBAN Account.    | String        |
| `BankAPI.getIBANByCharIdentifier(charIdentifier)`   | Returns the player IBAN Account (if available).   | String        |
| `BankAPI.getAccountMoney(iban, account)`                                  | Returns the account money (Cash / Gold) from an IBAN Account.                                                                                                                                                              | Integer       |
| `BankAPI.executeTransactionType(iban, transactionType, account, amount)`  | Executes transaction type ( DEPOSIT, WITHDRAW ).                                                                                                                                                                           | N/A           |
| `BankAPI.getBankAccounts()`                                               | Returns all the available Bank Accounts.                                                                                                                                                                                   | Table         |


## Parameters Explanation

| Parameter                                                                          | Description                                                                                                                                          |
|------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| `iban`                                                                             | Requires the IBAN account on a string form (text).                                                                                                   | 
| `source`                                                                           | Requires an online player id source target                                                                                                           | 
| `charIdentifier`                                                                   | Requires an online or offline player character identifier.                                                       | 
| `account`                                                                          | The available account types are `CASH` and `GOLD`                                                                                                    | 
| `transactionType`                                                                  | The available transaction types are `DEPOSIT` and `WITHDRAW`                                                                                         | 

## Screenshot Displays

