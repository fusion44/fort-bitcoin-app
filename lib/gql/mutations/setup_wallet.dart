/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

String lnCreateWalletQuery = """
mutation createLightningWallet(\$name: String!, \$publicAlias: String, \$autopilot: Boolean = true) {
  createLightningWallet(name: \$name, publicAlias: \$publicAlias, autopilot: \$autopilot) {
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

String lnGenSeedQuery = """
{
  lnGenSeed {
    __typename
    ... on GenSeedSuccess {
      lnSeed {
        cipherSeedMnemonic
        encipheredSeed
      }
    }
    ... on ServerError {
      errorMessage
    }
    ... on GenSeedError {
      errorMessage
    }
  }
}
""";

String lnInitWallet = """
mutation initWallet(\$aezeedPassphrase: String, \$cipherSeedMnemonic: [String], \$recoveryWindow: Int, \$walletPassword: String!) {
  lnInitWallet(aezeedPassphrase: \$aezeedPassphrase, cipherSeedMnemonic: \$cipherSeedMnemonic, recoveryWindow: \$recoveryWindow, walletPassword: \$walletPassword) {
    __typename
    ... on ServerError {
      errorMessage
    }
    ... on InitWalletError {
      errorMessage
    }
    ... on InitWalletSuccess {
      status
    }
  }
}
""";
