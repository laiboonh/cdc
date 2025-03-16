defmodule Cdc.Accounts.Transaction do
  @type t :: %__MODULE__{}

  defstruct [:amount, :created_on]
end
