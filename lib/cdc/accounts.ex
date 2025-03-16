defmodule Cdc.Accounts do
  alias Cdc.Accounts.Account

  @spec create_account(String.t(), Money.t()) :: {:ok, Account.t()} | {:error, :negative_balance}
  def create_account(name, balance) do
    cond do
      balance |> Money.negative?() -> {:error, :negative_balance}
      balance |> Money.zero?() -> {:ok, %Account{name: name}}
      true -> %Account{name: name} |> create_transaction(balance)
    end
  end

  @spec create_transaction(Account.t(), Money.t()) :: {:ok, Account.t()} | {:error, :zero_amount}
  def create_transaction(account, amount) do
    if amount |> Money.zero?() do
      {:error, :zero_amount}
    else
      {:ok, Map.update!(account, :transactions, fn transactions -> [amount | transactions] end)}
    end
  end
end
