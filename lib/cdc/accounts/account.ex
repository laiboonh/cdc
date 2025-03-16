defmodule Cdc.Accounts.Account do
  @type t :: %__MODULE__{}

  defstruct name: "", balance: Money.parse("0"), transactions: []
end
