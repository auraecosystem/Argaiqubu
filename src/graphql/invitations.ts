import gql from "graphql-tag";

export const GROUP_INVITATIONS_LIST = gql`
  query ListInvitation($groupId: ID!) {
    listInvitations(groupId: $groupId) {
      label
      token
    }
  }
`;

export const GROUP_INVITATIONS_CREATE = gql`
  mutation CreateInvitation($groupId: ID!, $label: String) {
    createInvitation(groupId: $groupId, label: $label) {
      label
      token
    }
  }
`;

export const GROUP_INVITATIONS_UPDATE = gql`
  mutation UpdateInvitation($groupId: ID!, $token: String!, $label: String) {
    updateInvitation(groupId: $groupId, token: $token, label: $label) {
      label
      token
    }
  }
`;

export const GROUP_INVITATIONS_DELETE = gql`
  mutation DeleteInvitation($groupId: ID!, $token: String!) {
    deleteInvitation(groupId: $groupId, token: $token) {
      label
      token
    }
  }
`;

export const GROUP_INVITATIONS_ACCEPT = gql`
  mutation acceptInvitationToken(
    $groupId: ID!
    $token: String!
    $actorId: ID!
  ) {
    acceptInvitationToken(groupId: $groupId, token: $token, actorId: $actorId) {
      id
      role
    }
  }
`;
