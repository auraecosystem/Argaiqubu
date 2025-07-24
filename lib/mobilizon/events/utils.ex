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

  def generate_occurrences(%Event{} = event) do
    rules = Map.get(event, :recurrence_rules) || []

    rules
    |> Enum.flat_map(&generate_for_rule(event.begins_on, &1))
    |> Enum.sort_by(& &1)
    |> Enum.map(fn x -> create_reocurring_event(x, event) end)
  end

  def deep_struct_to_map(%_{} = struct) do
    struct
    |> Map.from_struct()
    |> Enum.map(fn {key, value} ->
      {key, deep_struct_to_map(value)}
    end)
    |> Enum.into(%{})
  end

  def deep_struct_to_map(list) when is_list(list) do
    Enum.map(list, &deep_struct_to_map/1)
  end

  def deep_struct_to_map(value), do: value

  defp create_reocurring_event(%DateTime{} = start_on, %Event{} = event) do
    # hours_diff = DateTime.diff(event.begins_on, event.ends_on, :hour)
    ends_on = DateTime.add(start_on, 2, :hour)

    %Event{
      event
      | begins_on: start_on,
        ends_on: ends_on
    }
    |> Map.drop([:url, :uuid])
    |> deep_struct_to_map()
  end

  def recurrence_stream(begins_on, :daily, interval, until, count, _byday) do
    stream = Stream.iterate(begins_on, &Timex.shift(&1, seconds: interval))

    stream = Stream.take_while(stream, &(DateTime.compare(&1, until) != :gt))
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
  def generate_for_rule(
        %DateTime{} = dtstart,
        %RecurrenceRule{until: until} = rule,
        opts \\ []
      )
      when is_struct(until, DateTime) or is_nil(until) do
    dtstart = shift_forward(dtstart, rule.freq, rule.interval)
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
    |> filter_start_end_options(opts, default_end_date)
  end

  @spec shift_forward(DateTime.t(), :hourly | :daily | :weekly | :monthly, integer()) ::
          DateTime.t()
  def shift_forward(datetime, :hourly, n) when is_integer(n) do
    Timex.shift(datetime, hours: n)
  end

  def shift_forward(datetime, :daily, n) when is_integer(n) do
    Timex.shift(datetime, days: n)
  end

  def shift_forward(datetime, :weekly, n) when is_integer(n) do
    Timex.shift(datetime, weeks: n)
  end

  def shift_forward(datetime, :monthly, n) when is_integer(n) do
    Timex.shift(datetime, months: n)
  end

  def shift_forward(_datetime, freq, _n) do
    raise ArgumentError, "Unsupported frequency: #{inspect(freq)}"
  end

  def filter_start_end_options(limited, opts, default_end_date) do
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
