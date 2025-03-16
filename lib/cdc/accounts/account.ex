defmodule Cdc.Accounts.Account do
  @type t :: %__MODULE__{}

  defstruct name: "", transactions: []
end
