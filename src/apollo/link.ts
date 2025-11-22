import { from } from "@apollo/client/core";
import { createHttpLink } from "@apollo/client";
import { RetryLink } from "@apollo/client/link/retry";
import { removeTypenameFromVariables } from "@apollo/client/link/remove-typename";
import { authMiddleware } from "@/apollo/auth";
import errorLink from "@/apollo/error-link";
import { GRAPHQL_API_ENDPOINT, GRAPHQL_API_FULL_PATH } from "@/api/_entrypoint";

// Endpoints
const httpServer = GRAPHQL_API_ENDPOINT || "http://localhost:4000";
const httpEndpoint = GRAPHQL_API_FULL_PATH || `${httpServer}/api`;

const uploadLink = createHttpLink({
  uri: httpEndpoint,
});

const retryLink = new RetryLink();

export const fullLink = from([
  removeTypenameFromVariables(),
  retryLink,
  errorLink,
  authMiddleware,
  uploadLink,
]);
