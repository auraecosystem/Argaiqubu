defmodule Mobilizon.Events.UtilsTest do
  use Mobilizon.DataCase, async: true

  alias Mobilizon.Events.Event
  alias Mobilizon.Events.RecurrenceRule
  alias Mobilizon.Events.Utils

  @now ~U[2021-11-19T18:17:00Z]

  describe "calculate_notification_time" do
    test "when the event begins in less than 30 minutes" do
      begins_on = ~U[2021-11-19T18:27:00Z]
      assert @now == Utils.calculate_notification_time(begins_on, now: @now)
    end

    test "when the event begins in more than 30 minutes" do
      begins_on = ~U[2021-11-19T18:17:00Z]
      assert begins_on == Utils.calculate_notification_time(begins_on, now: @now)
    end
  end

  describe "generate_for_rule/3" do
    test "generates daily occurrences using count" do
      begins_on = DateTime.utc_now()
      end_of_reocurring_events = Timex.add(DateTime.utc_now(), Timex.Duration.from_days(5))

      rule = %RecurrenceRule{
        freq: :daily,
        interval: 1,
        until: end_of_reocurring_events
      }

      assert length(Utils.generate_for_rule(begins_on, rule)) == 6
    end

    test "generates weekly occurrences using until" do
      dtstart = ~U[2025-07-01 00:00:00Z]

      rule = %RecurrenceRule{
        freq: :weekly,
        interval: 1,
        until: ~U[2025-07-29 00:00:00Z]
      }

      assert Utils.generate_for_rule(dtstart, rule) == [
               ~U[2025-07-01 00:00:00Z],
               ~U[2025-07-08 00:00:00Z],
               ~U[2025-07-15 00:00:00Z],
               ~U[2025-07-22 00:00:00Z],
               ~U[2025-07-29 00:00:00Z]
             ]
    end

    test "filters by start_date and end_date" do
      dtstart = ~U[2025-07-01 00:00:00Z]

      rule = %RecurrenceRule{
        freq: :daily,
        interval: 1,
        count: 10
      }

      result =
        Utils.generate_for_rule(dtstart, rule,
          start_date: ~U[2025-07-03 00:00:00Z],
          end_date: ~U[2025-07-06 00:00:00Z]
        )

      assert result == [
               ~U[2025-07-03 00:00:00Z],
               ~U[2025-07-04 00:00:00Z],
               ~U[2025-07-05 00:00:00Z],
               ~U[2025-07-06 00:00:00Z]
             ]
    end

    test "applies default end_date as one month from dtstart" do
      dtstart = ~U[2025-07-01 00:00:00Z]

      rule = %RecurrenceRule{
        freq: :daily,
        interval: 1,
        count: 100
      }

      result = Utils.generate_for_rule(dtstart, rule)
      last = List.last(result)

      assert last <= Timex.shift(dtstart, months: 1)
      assert length(result) < 100
    end

    test "returns empty list when all events are filtered out" do
      dtstart = ~U[2025-07-01 00:00:00Z]

      rule = %RecurrenceRule{
        freq: :daily,
        interval: 1,
        count: 5
      }

      result =
        Utils.generate_for_rule(dtstart, rule,
          start_date: ~U[2025-07-10 00:00:00Z],
          end_date: ~U[2025-07-15 00:00:00Z]
        )

      assert result == []
    end

    test "raises error when neither count nor until is provided" do
      dtstart = ~U[2025-07-01 00:00:00Z]

      rule = %RecurrenceRule{
        freq: :daily,
        interval: 1
      }

      assert_raise ArgumentError, ~r/must include either :count or :until/, fn ->
        Utils.generate_for_rule(dtstart, rule)
      end
    end
  end

  @begins_on ~U[2025-07-01 09:00:00Z]
  @ends_on ~U[2025-07-01 10:00:00Z]

  defp base_event do
    %Event{
      title: "Yoga Class",
      begins_on: @begins_on,
      ends_on: @ends_on,
      recurrence_rules: nil
    }
  end

  describe "generate_for_rule" do
    test "filters occurrences by start_date and end_date" do
      dtstart = ~U[2025-07-01 00:00:00Z]

      rule = %RecurrenceRule{
        freq: :daily,
        interval: 1,
        count: 10
      }

      result =
        Utils.generate_for_rule(dtstart, rule,
          start_date: ~U[2025-07-03 00:00:00Z],
          end_date: ~U[2025-07-06 00:00:00Z]
        )

      assert result == [
               ~U[2025-07-03 00:00:00Z],
               ~U[2025-07-04 00:00:00Z],
               ~U[2025-07-05 00:00:00Z],
               ~U[2025-07-06 00:00:00Z]
             ]
    end

    test "returns all when start_date and end_date are nil" do
      dtstart = ~U[2025-07-01 00:00:00Z]

      rule = %RecurrenceRule{
        freq: :daily,
        interval: 1,
        count: 3
      }

      result = Utils.generate_for_rule(dtstart, rule)
      assert length(result) == 3
    end

    test "returns empty list when all events are filtered out" do
      dtstart = ~U[2025-07-01 00:00:00Z]

      rule = %RecurrenceRule{
        freq: :daily,
        interval: 1,
        count: 5
      }

      result =
        Utils.generate_for_rule(dtstart, rule)

      assert result == []
    end
  end

  describe "generate_occurrences/2 with multiple recurrence rules" do
    test "generates a daily recurrence stream" do
      start_time = ~U[2025-07-01 00:00:00Z]

      rule = %RecurrenceRule{
        freq: :daily,
        interval: 1
      }

      stream = Utils.recurrence_stream(start_time, rule)
      first_five_dates = Enum.take(stream, 5)

      assert first_five_dates == [
               ~U[2025-07-01 00:00:00Z],
               ~U[2025-07-02 00:00:00Z],
               ~U[2025-07-03 00:00:00Z],
               ~U[2025-07-04 00:00:00Z],
               ~U[2025-07-05 00:00:00Z]
             ]
    end

    test "combines daily and weekly rules" do
      daily = %RecurrenceRule{
        freq: :daily,
        interval: 1,
        until: ~U[2025-07-06 00:00:00Z]
      }

      event =
        base_event()
        |> Map.put(:recurrence_rules, [daily])

      result =
        Utils.generate_occurrences(event)

      dates = Enum.map(result, &DateTime.to_date(&1.begins_on))

      assert ~D[2025-07-01] in dates
      assert ~D[2025-07-03] in dates
      assert ~D[2025-07-05] in dates
      assert ~D[2025-07-04] in dates
      assert Enum.uniq(dates) == dates
    end

    test "returns empty list if rules list is empty" do
      event = base_event() |> Map.put(:recurrence_rules, [])
      result = Utils.generate_occurrences(event)
      assert result == []
    end

    test "ignores nil recurrence_rules field" do
      event = base_event()

      # , %{from: @begins_on, to: @ends_on})
      result = Utils.generate_occurrences(event)
      assert result == []
    end
  end
end
