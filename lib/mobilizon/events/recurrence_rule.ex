defmodule Mobilizon.Events.RecurrenceRule do
  @moduledoc """
  This module represents a RecurrenceRule using iCalendar recurrence rule as a blue print 
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          freq: :secondly | :minutely | :hourly | :daily | :weekly | :monthly | :yearly,
          event_id: integer(),
          interval: integer(),
          until: DateTime.t() | nil,
          count: integer() | nil,
          bysecond: [integer()],
          byminute: [integer()],
          byhour: [integer()],
          byday: [String.t()],
          bymonthday: [integer()],
          byyearday: [integer()],
          byweekno: [integer()],
          bymonth: [integer()],
          bysetpos: [integer()],
          wkst: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @attrs [
    :freq,
    :event_id,
    :interval,
    :until,
    :count,
    :bysecond,
    :byminute,
    :byhour,
    :byday,
    :bymonthday,
    :byyearday,
    :byweekno,
    :bymonth,
    :bysetpos,
    :wkst
  ]

  schema "recurrence_rules" do
    field :freq, Ecto.Enum,
      values: [:secondly, :minutely, :hourly, :daily, :weekly, :monthly, :yearly]

    field :interval, :integer, default: 1
    field :until, :utc_datetime
    field :count, :integer

    field :bysecond, {:array, :integer}, default: []
    field :byminute, {:array, :integer}, default: []
    field :byhour, {:array, :integer}, default: []
    field :byday, {:array, :string}, default: []
    field :bymonthday, {:array, :integer}, default: []
    field :byyearday, {:array, :integer}, default: []
    field :byweekno, {:array, :integer}, default: []
    field :bymonth, {:array, :integer}, default: []
    field :bysetpos, {:array, :integer}, default: []

    # Week start, e.g., "MO", "SU"
    field :wkst, :string, default: "MO"
    belongs_to :event, Mobilizon.Actors.Event

    timestamps()
  end

  @doc false
  def changeset(rule, attrs) do
    rule
    |> cast(attrs, @attrs)
    |> validate_required([:freq, :event_id])
    |> validate_number(:interval, greater_than: 0)
    |> validate_inclusion(:wkst, ~w(MO TU WE TH FR SA SU))
  end

  defp validate_mutual_exclusion(changeset, fields) do
    present = Enum.filter(fields, fn field -> get_field(changeset, field) end)

    if length(present) > 1 do
      add_error(changeset, hd(fields), "only one of #{Enum.join(fields, " or ")} can be set")
    else
      changeset
    end
  end
end
