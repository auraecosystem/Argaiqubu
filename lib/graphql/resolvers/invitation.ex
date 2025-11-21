defmodule Mobilizon.GraphQL.Resolvers.Invitation do
  @moduledoc """
  Handles the invitation-related GraphQL calls
  """

  alias Mobilizon.Actors
  alias Mobilizon.Actors.Actor
  alias Mobilizon.Invitation
  alias Mobilizon.Invitations
  import Mobilizon.Web.Gettext

  defp authorize_group_admin(%Actor{id: actor_id}, group_id) do
    if Actors.administrator?(actor_id, group_id) do
      :ok
    else
      {:error, dgettext("errors", "Profile is not administrator for the group")}
    end
  end

  def create_invitation(_parent, %{group_id: group_id} = args, %{
        context: %{current_actor: %Actor{} = updater_actor}
      }) do
    with :ok <- authorize_group_admin(updater_actor, group_id),
         {:ok, invitation} <- Invitations.create_invitation(args) do
      {:ok, invitation}
    else
      {:error, _} ->
        {:error, dgettext("errors", "Impossible to create the invitation")}

      error ->
        error
    end
  end

  def list_invitations(_parent, %{group_id: group_id}, %{
        context: %{current_actor: %Actor{} = updater_actor}
      }) do
    with :ok <- authorize_group_admin(updater_actor, group_id) do
      {:ok, Invitations.list_invitations(group_id)}
    end
  end

  def update_invitation(_parent, %{group_id: group_id, token: token} = args, %{
        context: %{current_actor: %Actor{} = updater_actor}
      }) do
    with :ok <- authorize_group_admin(updater_actor, group_id) do
      Invitations.update_invitation_by_token(group_id, token, args)
    end
  end

  def delete_invitation(_parent, %{group_id: group_id, token: token}, %{
        context: %{current_actor: %Actor{} = updater_actor}
      }) do
    with :ok <- authorize_group_admin(updater_actor, group_id) do
      Invitations.delete_invitation_by_token(group_id, token)
    end
  end

  def accept_invitation_token(
        _parent,
        %{group_id: group_id, token: token, actor_id: actor_id_chosen},
        %{
          context: %{current_actor: %Actor{id: actor_id_connected}}
        }
      ) do
    with true <-
           String.to_integer(actor_id_chosen) == actor_id_connected ||
             {:error, "You can only accept invitations for your own account"},
         %Invitation{} = _invitation <-
           Invitations.find_invitation(group_id, token) ||
             {:error, "Invalid invitation token for this group"},
         false <-
           Mobilizon.Actors.member?(actor_id_connected, group_id),
         {:ok, member} <-
           Mobilizon.Actors.create_member(%{
             role: :member,
             parent_id: group_id,
             actor_id: actor_id_connected
           }) do
      {:ok, member}
    else
      {:error, _} = error -> error
      true -> {:error, "You are already a member of this group"}
      _ -> {:error, "Unexpected error"}
    end
  end
end
