/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

String lnCreateWalletQuery = """
mutation createLightningWallet(\$name: String!, \$publicAlias: String) {
  createLightningWallet(name: \$name, publicAlias: \$publicAlias) {
    __typename
    ... on Unauthenticated {
      errorMessage
    }
    ... on CreateWalletExistsError {
      errorMessage
    }
    ... on CreateWalletSuccess {
      wallet {
        id
        publicAlias
        name
        testnet
        initialized
      }
    }
  }
}
""";
