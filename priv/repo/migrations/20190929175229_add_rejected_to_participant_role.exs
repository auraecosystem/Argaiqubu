defmodule Mobilizon.Storage.Repo.Migrations.AddRejectedToParticipantRole do
  use Ecto.Migration

  alias Mobilizon.Events.Enums.ParticipantRole
  alias Mobilizon.Events.Participan
  alias Mobilizon.Storage.Repo

  import Ecto.Query

  @disable_ddl_transaction true

  def up do
    Ecto.Migration.execute(
      "ALTER TYPE #{ParticipantRole.type()} ADD VALUE IF NOT EXISTS 'rejected'"
    )
  end

  def down do
    Participant
    |> where(role: "rejected")
    |> Repo.delete_all()
  end
end
