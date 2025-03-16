defmodule Cdc.Accounts do
  alias Cdc.Accounts.Transaction
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
          {:ok, Account.t()} | {:error, :negative_amount | :zero_amount | :negative_balance}
  def deposit(account, amount) do
    if amount |> Money.negative?() do
      {:error, :negative_amount}
    else
      create_transaction(account, amount)
    end
  end

  @spec withdraw(Account.t(), Money.t()) ::
          {:ok, Account.t()} | {:error, :negative_amount | :zero_amount | :negative_balance}
  def withdraw(account, amount) do
    if amount |> Money.negative?() do
      {:error, :negative_amount}
    else
      create_transaction(account, amount |> Money.negate!())
    end
  end

  @spec transfer(Account.t(), Account.t(), Money.t()) ::
          {:ok, Account.t(), Account.t()}
          | {:error, :negative_amount | :zero_amount | :negative_balance}
  def transfer(from_account, to_account, amount) do
    with false <- from_account == to_account,
         {:ok, from_account} <- withdraw(from_account, amount),
         {:ok, to_account} <- deposit(to_account, amount) do
      {:ok, from_account, to_account}
    else
      true ->
        {:error, :same_account}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec account_history(Account.t()) :: [Money.t()]
  def account_history(account),
    do:
      account.transactions
      |> Enum.sort(fn elem1, elem2 -> elem1.created_on |> DateTime.after?(elem2.created_on) end)

  @spec create_transaction(Account.t(), Money.t()) ::
          {:ok, Account.t()} | {:error, :zero_amount | :negative_balance}
  defp create_transaction(account, amount) do
    if amount |> Money.zero?() do
      {:error, :zero_amount}
    else
      transaction = %Transaction{amount: amount, created_on: DateTime.now!("Etc/UTC")}
      transactions = [transaction | account.transactions]

      balance =
        transactions
        |> Enum.reduce(Money.parse("0"), fn %{amount: amount}, acc -> Money.add!(acc, amount) end)

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
