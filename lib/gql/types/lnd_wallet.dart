/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

class LNDWallet {
  int id;
  String publicAlias;
  String name;
  bool testnet;
  bool initialized;

  LNDWallet(wallet) {
    id = int.parse(wallet["id"]);
    publicAlias = wallet["publicAlias"];
    name = wallet["name"];
    testnet = wallet["testnet"];
    initialized = wallet["initialized"];
  }
}
