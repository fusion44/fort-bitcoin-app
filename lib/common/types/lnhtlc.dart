/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

class LnHTLC {
  bool incoming;
  int amount;
  String hashLock;
  int expirationHeight;

  LnHTLC(Map<String, dynamic> data) {
    incoming = data["incoming"];
    amount = data["amount"];
    hashLock = data["hashLock"];
    expirationHeight = data["expirationHeight"];
  }
}
