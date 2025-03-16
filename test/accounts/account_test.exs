defmodule Accounts.AccountTest do
  use ExUnit.Case
  doctest Cdc

  require Assertions
  import Assertions, only: [assert_lists_equal: 2]

  describe "create_account" do
    test "when balance is less than 0" do
      assert Cdc.Accounts.create_account("foo", Money.from_float(:SGD, -1.23)) ==
               {:error, :negative_balance}
    end

    test "when balance is more than 0" do
      assert Cdc.Accounts.create_account("foo", Money.new(:SGD, 0)) ==
               {:ok,
                %Cdc.Accounts.Account{
                  name: "foo",
                  balance: Money.new(:SGD, "0"),
                  transactions: []
                }}
    end

    test "when balance is 0" do
      {:ok,
       %Cdc.Accounts.Account{
         name: "foo",
         balance: balance,
         transactions: transactions
       }} = Cdc.Accounts.create_account("foo", Money.from_float(:SGD, 1.23))

      assert balance == Money.new(:SGD, "1.23")

      assert_lists_equal(
        transactions |> Enum.map(fn elem -> Map.put(elem, :created_on, nil) end),
        [
          %Cdc.Accounts.Transaction{
            amount: Money.new(:SGD, "1.23")
          }
        ]
      )
    end
  end

  describe "deposit" do
    setup do
      {:ok, account} = Cdc.Accounts.create_account("foo", Money.from_float(:SGD, 1.23))
      %{account: account}
    end

    test "when amount is less than 0", %{account: account} do
      assert Cdc.Accounts.deposit(account, Money.from_float(:SGD, -1.23)) ==
               {:error, :negative_amount}
    end

    test "when amount is 0" do
      assert Cdc.Accounts.deposit("foo", Money.new(:SGD, 0)) == {:error, :zero_amount}
    end

    test "when balance is more than 0", %{account: account} do
      {:ok, %Cdc.Accounts.Account{name: "foo", balance: balance, transactions: transactions}} =
        Cdc.Accounts.deposit(account, Money.from_float(:SGD, 4.56))

      assert balance == Money.new(:SGD, "5.79")

      assert_lists_equal(
        transactions |> Enum.map(fn elem -> Map.put(elem, :created_on, nil) end),
        [
          %Cdc.Accounts.Transaction{amount: Money.new(:SGD, "4.56")},
          %Cdc.Accounts.Transaction{amount: Money.new(:SGD, "1.23")}
        ]
      )
    end
  end

  describe "withdraw" do
    setup do
      {:ok, account} =
        Cdc.Accounts.create_account("foo", Money.from_float(:SGD, 1.23))

      %{account: account}
    end

    test "when amount is less than 0", %{account: account} do
      assert Cdc.Accounts.withdraw(account, Money.from_float(:SGD, -1.23)) ==
               {:error, :negative_amount}
    end

    test "when amount is 0" do
      assert Cdc.Accounts.withdraw("foo", Money.new(:SGD, 0)) == {:error, :zero_amount}
    end

    test "when amount more than 0", %{account: account} do
      {:ok, %Cdc.Accounts.Account{name: "foo", balance: balance, transactions: transactions}} =
        Cdc.Accounts.withdraw(account, Money.from_float(:SGD, 0.05))

      assert balance == Money.new(:SGD, "1.18")

      assert_lists_equal(
        transactions |> Enum.map(fn elem -> Map.put(elem, :created_on, nil) end),
        [
          %Cdc.Accounts.Transaction{amount: Money.new(:SGD, "-0.05")},
          %Cdc.Accounts.Transaction{amount: Money.new(:SGD, "1.23")}
        ]
      )
    end

    test "when we overdraft", %{account: account} do
      assert Cdc.Accounts.withdraw(account, Money.from_float(:SGD, 4.56)) ==
               {:error, :negative_balance}
    end
  end

  describe "transfer" do
    setup do
      {:ok, from_account} = Cdc.Accounts.create_account("from", Money.from_float(:SGD, 1.23))
      {:ok, to_account} = Cdc.Accounts.create_account("to", Money.from_float(:SGD, 1.23))
      %{from_account: from_account, to_account: to_account}
    end

    test "success", %{from_account: from_account, to_account: to_account} do
      {:ok,
       %Cdc.Accounts.Account{
         name: "from",
         balance: from_balance,
         transactions: from_transactions
       },
       %Cdc.Accounts.Account{
         name: "to",
         balance: to_balance,
         transactions: to_transactions
       }} =
        Cdc.Accounts.transfer(from_account, to_account, Money.from_float(:SGD, 0.05))

      assert from_balance == Money.new(:SGD, "1.18")

      assert_lists_equal(
        from_transactions |> Enum.map(fn elem -> Map.put(elem, :created_on, nil) end),
        [
          %Cdc.Accounts.Transaction{amount: Money.new(:SGD, "-0.05")},
          %Cdc.Accounts.Transaction{amount: Money.new(:SGD, "1.23")}
        ]
      )

      assert to_balance == Money.new(:SGD, "1.28")

      assert_lists_equal(
        to_transactions |> Enum.map(fn elem -> Map.put(elem, :created_on, nil) end),
        [
          %Cdc.Accounts.Transaction{amount: Money.new(:SGD, "0.05")},
          %Cdc.Accounts.Transaction{amount: Money.new(:SGD, "1.23")}
        ]
      )
    end

    test "transfer resulting in overdraft fails", %{
      from_account: from_account,
      to_account: to_account
    } do
      assert Cdc.Accounts.transfer(from_account, to_account, Money.from_float(:SGD, 4.56)) ==
               {:error, :negative_balance}
    end

    test "same account fails", %{
      from_account: from_account
    } do
      assert Cdc.Accounts.transfer(from_account, from_account, Money.from_float(:SGD, 4.56)) ==
               {:error, :same_account}
    end
  end

  describe "account_history" do
    test "returns a list of account's transaction (latest first)" do
      {:ok, account} =
        Cdc.Accounts.create_account("foo", Money.from_float(:SGD, 1.23))

      {:ok, account} = Cdc.Accounts.deposit(account, Money.parse("4.56"))
      {:ok, account} = Cdc.Accounts.deposit(account, Money.parse("2.34"))

      transactions = Cdc.Accounts.account_history(account)

      assert transactions |> Enum.map(fn elem -> Map.put(elem, :created_on, nil) end) == [
               %Cdc.Accounts.Transaction{amount: Money.new(:SGD, "2.34")},
               %Cdc.Accounts.Transaction{amount: Money.new(:SGD, "4.56")},
               %Cdc.Accounts.Transaction{amount: Money.new(:SGD, "1.23")}
             ]
    end
  end
end
