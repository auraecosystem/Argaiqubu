defmodule Mobilizon.Invitations do
  @moduledoc """
  The Invitations context.
  """

  alias Mobilizon.Invitation
  alias Mobilizon.Storage.Repo
  import Ecto.Query

  def get_invitation(id), do: Repo.get(Invitation, id)

  def create_invitation(attrs \\ %{}) do
    %Invitation{}
    |> Invitation.changeset(attrs)
    |> Repo.insert()
  end

  def update_invitation_by_token(group_id, token, attrs) do
    case Repo.get_by(Mobilizon.Invitation, token: token, group_id: group_id) do
      nil ->
        {:error, "Invitation not found"}

      %Mobilizon.Invitation{} = invitation ->
        invitation
        |> Invitation.changeset(attrs)
        |> Repo.update()
    end
  end

  def delete_invitation_by_token(group_id, token) do
    case Repo.get_by(Mobilizon.Invitation, token: token, group_id: group_id) do
      nil -> {:error, "Invitation not found"}
      invitation -> Repo.delete(invitation)
    end
  end

  def list_invitations(group_id) do
    Invitation
    |> where([i], i.group_id == ^group_id)
    |> Repo.all()
  end
end
