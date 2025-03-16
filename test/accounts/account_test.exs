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
      assert Cdc.Accounts.create_account("foo", Money.from_float(:SGD, 1.23)) ==
               {:ok,
                %Cdc.Accounts.Account{
                  name: "foo",
                  balance: Money.new(:SGD, "1.23"),
                  transactions: [Money.new(:SGD, "1.23")]
                }}
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
      assert_lists_equal(transactions, [Money.new(:SGD, "1.23"), Money.new(:SGD, "4.56")])
    end
  end

  describe "withdraw" do
    setup do
      {:ok, account} = Cdc.Accounts.create_account("foo", Money.from_float(:SGD, 1.23))
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
      assert_lists_equal(transactions, [Money.new(:SGD, "1.23"), Money.new(:SGD, "-0.05")])
    end

    test "when we overdraft", %{account: account} do
      assert Cdc.Accounts.withdraw(account, Money.from_float(:SGD, 4.56)) ==
               {:error, :negative_balance}
    end
  end
end
