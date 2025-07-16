defmodule Mobilizon.Events.Utils do
  @moduledoc """
  Utils related to events
  """

  alias Mobilizon.Events.Event
  alias Mobilizon.Events.RecurrenceRule

  @spec calculate_notification_time(DateTime.t()) :: DateTime.t()
  def calculate_notification_time(begins_on, options \\ []) do
    now = Keyword.get(options, :now, DateTime.utc_now())
    notify_at = DateTime.add(now, 1800)

    # If the event begins in less than half an hour, send the notification right now
    if DateTime.compare(notify_at, begins_on) == :lt do
      notify_at
    else
      now
    end
  end

  def generate_occurrences(%Event{} = event, %{
        from: %DateTime{} = _from_date,
        to: %DateTime{} = _to_date
      }) do
    rules = Map.get(event, :recurrence_rules) || []

    rules
    |> Enum.flat_map(&generate_for_rule(event.begins_on, &1))
    |> Enum.sort_by(& &1)
    |> Enum.map(fn x -> create_reocurring_event(x, event) end)
  end

  defp create_reocurring_event(%DateTime{} = start_on, %Event{} = event) do
    hours_diff = DateTime.diff(event.begins_on, event.ends_on, :hour)
    ends_on = DateTime.add(start_on, hours_diff, :hour)
    %Event{event | begins_on: start_on, ends_on: ends_on}
  end

  def recurrence_stream(begins_on, :daily, interval, until, count, _byday) do
    stream = Stream.iterate(begins_on, &Timex.shift(&1, seconds: interval))

    stream = Stream.take_while(stream, &(DateTime.compare(&1, until) != :gt))
    if count, do: Stream.take(stream, count), else: stream
  end

  @doc """
  Generates a stream of `DateTime` values based on a recurrence rule.

  This function implements recurrence logic similar to iCalendar RRULEs using the following subset:
  - `:freq` — currently supports `:daily` and `:weekly`
  - `:interval` — number of units between each occurrence
  - `:until` — a `DateTime` marking the upper bound of recurrence
  - `:count` — maximum number of occurrences (optional)
  - `:byday` — used with `:weekly` to specify which weekdays to include (e.g. ["MO", "FR"])

  ## Parameters

    - `start_time` (`DateTime`) — the datetime to begin recurrence generation from.
    - `freq` (`:daily | :weekly`) — the type of recurrence.
    - `interval` (`integer`) — how often the recurrence repeats (e.g. every 2 days/weeks).
    - `until` (`DateTime`) — the maximum datetime limit for recurrence generation.
    - `count` (`integer | nil`) — maximum number of occurrences (optional).
    - `byday` (`[String.t()] | nil`) — applicable only to `:weekly`, determines days of week to include.

  ## Returns

    - A `Stream` of `DateTime` values representing each recurrence.

  ## Notes

    - `:daily` ignores `byday`.
    - `:weekly` requires `byday` to generate weekday-specific entries.
    - If both `until` and `count` are provided, `count` is applied **after** filtering by `until`.

  ## Example


  recurrence_stream(~U[2025-07-01 09:00:00Z], :weekly, 1, ~U[2025-07-31 00:00:00Z], nil, ["MO", "FR"])
  #=> Stream of Mondays and Fridays between July 1 and July 31, 2025
  """
  def recurrence_stream(begins_on, :weekly, interval, until, count, byday) do
    count = 4
    weekdays = Enum.map(byday, &weekday_to_int/1)

    stream =
      begins_on
      |> Stream.iterate(&Timex.shift(&1, weeks: interval))
      |> Stream.flat_map(fn base ->
        weekdays
        |> Enum.map(fn wd ->
          bg_w = Timex.beginning_of_week(base, :mon)

          bg_w
          |> Timex.shift(days: wd - 1)
        end)
      end)
      |> Enum.sort()
      |> Stream.filter(&(DateTime.compare(&1, until) != :gt))

    if count, do: Stream.take(stream, count), else: stream
  end

  def recurrence_stream(%DateTime{} = dtstart, %RecurrenceRule{} = rule) do
    Stream.iterate(dtstart, fn current ->
      case rule.freq do
        :daily ->
          DateTime.add(current, rule.interval * 86_400, :second)

        :weekly ->
          DateTime.add(current, rule.interval * 7 * 86_400, :second)

        :monthly ->
          # This assumes current is a DateTime. Convert to Date for shifting.
          current
          |> DateTime.to_date()
          |> then(fn date -> Timex.shift(date, months: rule.interval) end)
          |> DateTime.new!(current |> DateTime.to_time(), current.time_zone)

        _ ->
          raise ArgumentError, "Unsupported frequency: #{inspect(rule.freq)}"
      end
    end)
  end

  @doc """
  Generates a finite list of recurrence datetimes from the given `dtstart` and `rule`.

  Accepts optional `:start_date` and `:end_date` filters.

  ## Options

    * `:start_date` - only include dates **on or after** this (inclusive)
    * `:end_date` - only include dates **on or before** this (inclusive).
      If not provided, defaults to one month after `dtstart`.

  ## Constraints from rule

  - If `rule.count` is given, limits the recurrence to that number of instances.
  - If `rule.until` is given, limits the recurrence until that datetime.

  Either `count` or `until` is required.

  ## Example

      generate_for_rule(~U[2025-07-01 00:00:00Z], %RecurrenceRule{
        frequency: :weekly,
        interval: 1,
        count: 10
      }, start_date: ~U[2025-07-08 00:00:00Z])
  """
  def generate_for_rule(%DateTime{} = dtstart, %RecurrenceRule{} = rule, opts \\ []) do
    stream = recurrence_stream(dtstart, rule)

    limited =
      cond do
        rule.count ->
          Enum.take(stream, rule.count)

        rule.until ->
          Enum.take_while(stream, fn dt -> DateTime.compare(dt, rule.until) != :gt end)

        true ->
          raise ArgumentError, "RecurrenceRule must include either :count or :until"
      end

    default_end_date = Timex.shift(dtstart, months: 1)

    limited
    |> Enum.filter(fn dt ->
      after_start? =
        case opts[:start_date] do
          nil -> true
          start -> DateTime.compare(dt, start) != :lt
        end

      before_end? =
        case Keyword.get(opts, :end_date, default_end_date) do
          nil -> true
          stop -> DateTime.compare(dt, stop) != :gt
        end

      after_start? and before_end?
    end)
  end

  defp weekday_to_int("MO"), do: 1
  defp weekday_to_int("TU"), do: 2
  defp weekday_to_int("WE"), do: 3
  defp weekday_to_int("TH"), do: 4
  defp weekday_to_int("FR"), do: 5
  defp weekday_to_int("SA"), do: 6
  defp weekday_to_int("SU"), do: 7
end
