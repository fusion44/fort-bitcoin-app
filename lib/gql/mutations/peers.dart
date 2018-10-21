/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

String connectPeerMutation = """
mutation ConnectPeerMutation(\$pubkey: String!, \$host: String!, \$perm: Boolean) {
  lnConnectPeer(pubkey: \$pubkey, host: \$host, perm: \$perm) {
    __typename
    ... on ConnectPeerSuccess {
      result
      pubkey
      
    }
    ... on ServerError {
      errorMessage
    }
    ... on ConnectPeerError {
      errorMessage
      pubkey
      host
    }
  }
}
""";

String disconnectPeerMutation = """
mutation DisconnectPeer(\$pubkey: String!) {
  lnDisconnectPeer(pubkey: \$pubkey) {
    __typename
    ... on DisconnectPeerSuccess {
      result
      pubkey
    }
    ... on ServerError {
      errorMessage
    }
    ... on DisconnectPeerError {
      errorMessage
      pubkey
    }
  }
}
""";
