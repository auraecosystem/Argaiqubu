defmodule Mobilizon.GraphQL.Schema.Custom.MoneyWithCurrency do
  @moduledoc """
  The MoneyWithCurrency scalar type allows money strings with currency to be passed in and out.
  Requires `{ :money, ">= 1.12" }` package: https://github.com/elixirmoney/money
  """
  use Absinthe.Schema.Notation

  scalar :money_with_currency, name: "MoneyWithCurrency" do
    description("""
    The `MoneyWithCurrency` scalar type represents a monetary value, consisting of an amount and a currency.
    """)

    serialize(&encode/1)
    parse(&decode/1)
  end

  @spec decode(Absinthe.Blueprint.Input.String.t()) :: {:ok, Money.t()} | :error
  @spec decode(Absinthe.Blueprint.Input.Null.t()) :: {:ok, nil}
  defp decode(%Absinthe.Blueprint.Input.String{value: value}) do
    with {:ok, %{"amount" => amount, "currency" => currency}} <- Jason.decode(value),
         {:ok, amount} <- Decimal.cast(amount),
         {:ok, %Money{}} = money <- Money.parse(amount, currency) do
      money
    else
      _ -> :error
    end
  end

  defp decode(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  defp decode(_) do
    :error
  end

  defp encode(%Money{amount: _amount, currency: currency} = money) do
    %{"amount" => Money.to_decimal(money), "currency" => Atom.to_string(currency)}
  end
end
