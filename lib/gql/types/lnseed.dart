/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

class LnSeed {
  List<String> cipherSeedMnemonic;
  String encipheredSeed;

  LnSeed(Map<String, dynamic> data) {
    cipherSeedMnemonic = List<String>.from(data["cipherSeedMnemonic"] ?? []);
    encipheredSeed = data["encipheredSeed"];
  }
}
