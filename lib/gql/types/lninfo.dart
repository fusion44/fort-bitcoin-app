/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

class LnInfoType {
  // The identity pubkey of the current node.
  String identity_pubkey;
  //If applicable, the alias of the current node, e.g. 'bob'
  String alias;
  // Number of pending channels
  int num_pending_channels;
  // Number of active channels
  int num_active_channels;
  // Number of peers
  int num_peers;
  // The node’s current view of the height of the best block
  int block_height;
  // The node’s current view of the hash of the best block
  int block_hash;
  // Whether the wallet’s view is synced to the main chain
  bool synced_to_chain;
  // Whether the current node is connected to testnet
  bool testnet;
  // A list of active chains the node is connected to
  List<String> chains;
  // The URIs of the current node.
  List<String> uris;
  // Timestamp of the block best known to the wallet
  int best_header_timestamp;
  //The version of the LND software that the node is running.
  String version;
}
