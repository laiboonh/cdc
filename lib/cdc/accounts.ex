defmodule Cdc.Accounts do
  alias Cdc.Accounts.Account

  @spec create_account(String.t(), Money.t()) ::
          {:ok, Account.t()} | {:error, :negative_balance | :zero_amount}
  def create_account(name, balance) do
    cond do
      balance |> Money.negative?() -> {:error, :negative_balance}
      balance |> Money.zero?() -> {:ok, %Account{name: name}}
      true -> %Account{name: name} |> create_transaction(balance)
    end
  end

  @spec deposit(Account.t(), Money.t()) ::
          {:ok, Account.t()} | {:error, :negative_amount | :zero_amount}
  def deposit(account, amount) do
    if amount |> Money.negative?() do
      {:error, :negative_amount}
    else
      create_transaction(account, amount)
    end
  end

  @spec withdraw(Account.t(), Money.t()) ::
          {:ok, Account.t()} | {:error, :negative_amount | :zero_amount}
  def withdraw(account, amount) do
    if amount |> Money.negative?() do
      {:error, :negative_amount}
    else
      create_transaction(account, amount |> Money.negate!())
    end
  end

  @spec create_transaction(Account.t(), Money.t()) :: {:ok, Account.t()} | {:error, :zero_amount}
  defp create_transaction(account, amount) do
    if amount |> Money.zero?() do
      {:error, :zero_amount}
    else
      transactions = [amount | account.transactions]

      balance =
        transactions |> Enum.reduce(Money.parse("0"), fn elem, acc -> Money.add!(acc, elem) end)

      if balance |> Money.negative?() do
        {:error, :negative_balance}
      else
        {:ok,
         account
         |> Map.put(:transactions, transactions)
         |> Map.put(:balance, balance)}
      end
    end
  end
end
