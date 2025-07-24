defmodule Mobilizon.Storage.Repo.Migrations.CreateRecurrenceRuleTable do
  use Ecto.Migration

  def change do
    create table(:recurrence_rules) do
      add :freq, :string, null: false
      add :interval, :integer, default: 1
      add :until, :utc_datetime
      add :count, :integer

      add :bysecond, {:array, :integer}, default: []
      add :byminute, {:array, :integer}, default: []
      add :byhour, {:array, :integer}, default: []
      add :byday, {:array, :string}, default: []
      add :bymonthday, {:array, :integer}, default: []
      add :byyearday, {:array, :integer}, default: []
      add :byweekno, {:array, :integer}, default: []
      add :bymonth, {:array, :integer}, default: []
      add :bysetpos, {:array, :integer}, default: []
      add :wkst, :string, default: "MO"
      add(:event_id, references(:events, on_delete: :delete_all))
      timestamps()
    end

    create(index(:recurrence_rules, [:event_id]))
  end
end
