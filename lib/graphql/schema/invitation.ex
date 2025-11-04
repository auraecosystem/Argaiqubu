defmodule Mobilizon.GraphQL.Schema.InvitationType do
  @moduledoc """
  Schema representation for Invitation
  """
  use Absinthe.Schema.Notation
  alias Mobilizon.GraphQL.Resolvers.Invitation

  @desc "A local invitation to a Mobilizon group"
  object :invitation do
    meta(:authorize, :user)
    field(:token, :string, description: "The invitation token")
    field(:label, :string, description: "The invitation label")
  end

  object :invitation_mutations do
    @desc "Create an invitation for a group"
    field :create_invitation, type: :invitation do
      arg(:group_id, non_null(:id), description: "ID of the group")
      arg(:label, :string, description: "Label")
      middleware(Rajska.QueryAuthorization, permit: :user, scope: false)
      resolve(&Invitation.create_invitation/3)
    end

    @desc "Update an invitation for a group"
    field :update_invitation, type: :invitation do
      arg(:group_id, non_null(:id), description: "ID of the group")
      arg(:token, :string, description: "Token")
      arg(:label, :string, description: "Label")
      middleware(Rajska.QueryAuthorization, permit: :user, scope: false)
      resolve(&Invitation.update_invitation/3)
    end

    @desc "Delete an invitation for a group"
    field :delete_invitation, type: :invitation do
      arg(:group_id, non_null(:id), description: "ID of the group")
      arg(:token, :string, description: "Token")
      middleware(Rajska.QueryAuthorization, permit: :user, scope: false)
      resolve(&Invitation.delete_invitation/3)
    end
  end

  object :invitation_queries do
    @desc "List all invitations for a group"
    field :list_invitations, non_null(list_of(:invitation)) do
      arg(:group_id, non_null(:id), description: "ID of the group")
      middleware(Rajska.QueryAuthorization, permit: :user, scope: false)
      resolve(&Invitation.list_invitations/3)
    end
  end
end
