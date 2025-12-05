import { from } from "@apollo/client/core";
import { RetryLink } from "@apollo/client/link/retry";
import { authMiddleware } from "./auth";
import errorLink from "./error-link";
import { uploadLink } from "./absinthe-upload-socket-link";
import { removeTypenameFromVariables } from "@apollo/client/link/remove-typename";

const retryLink = new RetryLink();

export const fullLink = from([
  removeTypenameFromVariables(),
  retryLink,
  errorLink,
  authMiddleware,
  uploadLink,
]);
