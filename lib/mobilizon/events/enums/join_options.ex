defmodule Mobilizon.Events.EventParticipantStats do
  @moduledoc """
  Participation stats on event
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          free: integer(),
          restricted: integer(),
          invite: integer(),
          external: integer()
        }

  @attrs [
    :free,
    :restricted,
    :invite,
    :external
  ]

  @primary_key false
  @derive Jason.Encoder
  embedded_schema do
    field(:free, :integer, default: 0)
    field(:restricted, :integer, default: 0)
    field(:invite, :integer, default: 0)
    field(:external, :integer, default: 0)
  end

  @doc false
  @spec changeset(t | Ecto.Schema.t(), map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = event_options, attrs) do
    event_options
    |> cast(attrs, @attrs)
    |> validate_stats()
  end

  defp validate_stats(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_number(:free, greater_than_or_equal_to: 0)
    |> validate_number(:restricted, greater_than_or_equal_to: 0)
    |> validate_number(:invite, greater_than_or_equal_to: 0)
    |> validate_number(:external, greater_than_or_equal_to: 0)
  end
end
