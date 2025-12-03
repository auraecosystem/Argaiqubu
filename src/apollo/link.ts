import { from, split } from "@apollo/client/core";
import { RetryLink } from "@apollo/client/link/retry";
import { getMainDefinition } from "@apollo/client/utilities";
import absintheSocketLink from "./absinthe-socket-link";
import { authMiddleware } from "./auth";
import errorLink from "./error-link";
import { uploadLink } from "./absinthe-upload-socket-link";
import { removeTypenameFromVariables } from "@apollo/client/link/remove-typename";

const retryLink = new RetryLink();

const link = split(
  // split based on operation type
  ({ query }) => {
    const definition = getMainDefinition(query);
    return (
      definition.kind === "OperationDefinition" &&
      definition.operation === "subscription"
    );
  },
  absintheSocketLink,
  uploadLink
);

export const fullLink = from([
  removeTypenameFromVariables(),
  retryLink,
  errorLink,
  authMiddleware,
  link ?? uploadLink,
]);
