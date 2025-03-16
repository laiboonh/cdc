# Cdc

## Pre requisite
- install `asdf`
- run `asdf install`

## To start REPL
- run `iex -S mix`

## Business Requirements
- Users can create a new bank account with a name and starting balance
```
iex(1)> {:ok, account} = Cdc.Accounts.create_account("foo", Money.from_float(:SGD, 1.23))
```
- Users can deposit money to their accounts
```
iex(2)> {:ok, account} = Cdc.Accounts.deposit(account, Money.from_float(:SGD, 1.23))
```
- Users can withdraw money from their accounts
```
iex(3)> {:ok, account} = Cdc.Accounts.withdraw(account, Money.from_float(:SGD, 0.05))
```
- Users are not allowed to overdraft their accounts
```
iex(4)> Cdc.Accounts.withdraw(account, Money.from_float(:SGD, 10.05))
{:error, :negative_balance}
```
- Users can transfer money to other accounts in the same banking system
```
iex(5)> {:ok, to_account} = Cdc.Accounts.create_account("bar", Money.from_float(:SGD, 1.23))
iex(6)> {:ok, account, to_accunt} = Cdc.Accounts.transfer(account, to_account, Money.from_float(:SGD, 1.23))
```
- Users can see their account transaction history
```
iex(7)> Cdc.Accounts.account_history(to_account)
```