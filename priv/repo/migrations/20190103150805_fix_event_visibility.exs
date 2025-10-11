defmodule Mobilizon.Repo.Migrations.FixEventVisibility do
  use Ecto.Migration

  alias Mobilizon.Discussions.CommentVisibility

  def up do
    Mobilizon.Events.Enums.EventVisibility.create_type()
    Mobilizon.Events.Enums.EventStatus.create_type()
    CommentVisibility.create_type()

    alter table(:events) do
      remove(:public)
      remove(:status)
      remove(:state)
      add(:visibility, Mobilizon.Events.Enums.EventVisibility.type())
      add(:status, Mobilizon.Events.Enums.EventStatus.type())
    end

    alter table(:comments) do
      add(:visibility, CommentVisibility.type())
    end
  end

  def down do
    alter table(:events) do
      remove(:visibility)
      remove(:status)
      add(:state, :integer, null: false, default: 0)
      add(:public, :boolean, null: false, default: false)
      add(:status, :integer, null: false, default: 0)
    end

    alter table(:comments) do
      remove(:visibility)
    end

    Mobilizon.Events.EventVisibility.drop_type()
    Mobilizon.Events.EventStatus.drop_type()
    CommentVisibility.drop_type()
  end
end
