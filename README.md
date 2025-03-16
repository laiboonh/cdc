# Cdc

## Pre requisite
- install `asdf`
- run `asdf install`

## To start REPL
- run `iex -S mix`

## Business Requirements
- Users can create a new bank account with a name and starting balance
```
iex(1)> Cdc.Accounts.create_account("foo", Money.new(:SGD, 1))
{:ok, %Cdc.Accounts.Account{name: "foo", transactions: [Money.new(:SGD, "1")]}}
```