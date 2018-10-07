/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

class LnInfoType {
  // The identity pubkey of the current node.
  String identityPubkey;
  //If applicable, the alias of the current node, e.g. 'bob'
  String alias;
  // Number of pending channels
  int numPendingChannels;
  // Number of active channels
  int numActiveChannels;
  // Number of peers
  int numPeers;
  // The node’s current view of the height of the best block
  int blockHeight;
  // The node’s current view of the hash of the best block
  String blockHash;
  // Whether the wallet’s view is synced to the main chain
  bool syncedToChain;
  // Whether the current node is connected to testnet
  bool testnet;
  // A list of active chains the node is connected to
  List<String> chains;
  // The URIs of the current node.
  List<String> uris;
  // Timestamp of the block best known to the wallet
  int bestHeaderTimestamp;
  //The version of the LND software that the node is running.
  String version;

  LnInfoType(Map<String, dynamic> data) {
    identityPubkey = data["identityPubkey"];
    alias = data["alias"];
    numPendingChannels = data["numPendingChannels"];
    numActiveChannels = data["numActiveChannels"];
    numPeers = data["numPeers"];
    blockHeight = data["blockHeight"];
    blockHash = data["blockHash"];
    syncedToChain = data["syncedToChain"];
    testnet = data["testnet"];
    chains = List<String>.from(data["chains"] ?? []);
    uris = List<String>.from(data["uris"] ?? []);
    bestHeaderTimestamp = data["bestHeaderTimestamp"];
    version = data["version"];
  }
}
