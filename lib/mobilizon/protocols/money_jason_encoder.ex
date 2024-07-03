defmodule Mobilizon.Protocols.MoneyJasonEncoder do
  @moduledoc """
  Implements the Jason.Encoder protocol for serializing Money structs.

  This JSON encoder implementation for Money structs is necessary because Oban
  requires serializable values.
  """

  defimpl Jason.Encoder, for: Money do
    @spec encode(Money.t(), Keyword.t()) :: Jason.Encode.opts()
    def encode(%Money{amount: amount, currency: currency}, opts) when is_integer(amount) do
      Jason.Encode.map(%{currency: currency, amount: amount}, opts)
    end

    def encode(%Money{amount: amount, currency: currency}, opts) when is_binary(amount) do
      Jason.Encode.map(%{currency: currency, amount: String.to_integer(amount)}, opts)
    end
  end
end
