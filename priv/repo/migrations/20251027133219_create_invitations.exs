defmodule Mobilizon.Storage.Repo.Migrations.CreateInvitations do
  use Ecto.Migration

  def change do
    create table(:invitations) do
      add(:label, :string, default: "", null: false)
      add(:token, :string, default: fragment("gen_random_uuid()"), null: false)
      add(:group_id, references(:actors, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index(:invitations, [:token]))
  end
end
