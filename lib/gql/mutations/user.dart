/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

String createUser = """
mutation createUser(\$username: String!, \$password: String!, \$email: String) {
  createUser(username: \$username, password: \$password, email: \$email) {
    createUser {
      __typename
      ... on CreateUserSuccess {
        user {
          id
          username
          email
        }
      }
      ... on CreateUserError {
        errorType
        errorMessage
      }
      ... on ServerError {
        errorMessage
      }
    }
  }
}
""";
