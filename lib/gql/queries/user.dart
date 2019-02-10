/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

String getWalletStatus = """
{
  getLnWalletStatus {
    __typename
    ... on Unauthenticated {
      errorMessage
    }
    ... on ServerError {
      errorMessage
    }
    ... on GetLnWalletStatusError {
      errorMessage
    }
    ... on WalletInstanceNotFound {
      errorMessage
      suggestions
    }
    ... on WalletInstanceNotRunning {
      errorMessage
      suggestions
    }
    ... on GetLnWalletStatusLocked {
      errorMessage
      suggestions
    }
    ... on GetLnWalletStatusOperational {
      info
    }
  }
}
""";

String getUserInfo = """
{
  getCurrentUser {
    __typename
    ... on Unauthenticated {
      errorMessage
    }
    ... on ServerError {
      errorMessage
    }
    ... on GetCurrentUserError {
      errorMessage
    }
    ... on GetCurrentUserSuccess {
      user {
        id
        username
      }
    }
  }
  getLnWalletStatus {
    __typename
    ... on Unauthenticated {
      errorMessage
    }
    ... on ServerError {
      errorMessage
    }
    ... on GetLnWalletStatusError {
      errorMessage
    }
    ... on WalletInstanceNotFound {
      errorMessage
      suggestions
    }
    ... on WalletInstanceNotRunning {
      errorMessage
      suggestions
    }
    ... on GetLnWalletStatusLocked {
      errorMessage
      suggestions
    }
    ... on GetLnWalletStatusOperational {
      info
    }
  }
}
""";
