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
    |> validate_required([:freq])
    |> validate_only_one_required(:until, :count)
    |> validate_number(:interval, greater_than: 0)
    |> validate_inclusion(:wkst, ~w(MO TU WE TH FR SA SU))
  end

  @doc """
  Ensures exactly one of the two fields is present (not both, not neither).
  """
  def validate_only_one_required(changeset, field1, field2) do
    val1 = get_field(changeset, field1)
    val2 = get_field(changeset, field2)

    cond do
      is_nil(val1) and is_nil(val2) ->
        add_error(changeset, field1, "either #{field1} or #{field2} must be present")

      not is_nil(val1) and not is_nil(val2) ->
        add_error(changeset, field2, "only one of #{field1} or #{field2} can be present")

      true ->
        changeset
    end
  end
end
