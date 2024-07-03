defmodule Mobilizon.Storage.Repo.Migrations.UpdateEventOptionsParticipationFee do
  use Ecto.Migration

  alias Mobilizon.Events.Event
  alias Mobilizon.Storage.Repo

  def change do
    events = Repo.all(Event)
    money = Money.new(0, :EUR)

    for event <- events do
      updated_options =
        event.options
        |> maybe_delete_and_put(:show_participation_price, :show_participation_fee)
        |> Map.put(:participation_fee, money)

      event
      |> Ecto.Changeset.change(options: updated_options)
      |> Repo.update!()
    end
  end

  defp maybe_delete_and_put(map, old_key, new_key) do
    case Map.has_key?(map, old_key) do
      true ->
        map
        |> Map.delete(old_key)
        |> Map.put(new_key, Map.get(map, old_key))

      false ->
        map
    end
  end
end
