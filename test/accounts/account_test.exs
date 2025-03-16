defmodule Accounts.AccountTest do
  use ExUnit.Case
  doctest Cdc

  describe "create_account" do
    test "when balance is less than 0" do
      assert Cdc.Accounts.create_account("foo", Money.from_float(:SGD, -1.23)) ==
               {:error, :negative_balance}
    end

    test "when balance is more than 0" do
      assert Cdc.Accounts.create_account("foo", Money.new(:SGD, 0)) ==
               {:ok, %Cdc.Accounts.Account{name: "foo", transactions: []}}
    end

    test "when balance is 0" do
      assert Cdc.Accounts.create_account("foo", Money.from_float(:SGD, 1.23)) ==
               {:ok, %Cdc.Accounts.Account{name: "foo", transactions: [Money.new(:SGD, "1.23")]}}
    end
  end
end
