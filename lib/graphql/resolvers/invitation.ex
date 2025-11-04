defmodule Mobilizon.GraphQL.Resolvers.Invitation do
  @moduledoc """
  Handles the invitation-related GraphQL calls
  """

  alias Mobilizon.Actors
  alias Mobilizon.Actors.Actor
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
        {:error, dgettext("errors", "could not create invitation")}

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
end
