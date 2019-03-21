/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

class LnChannelBalance {
  int balance;
  int pendingOpenBalance;

  LnChannelBalance(Map<String, dynamic> data) {
    balance = data["balance"] ?? 0;
    pendingOpenBalance = data["pendingOpenBalance"] ?? 0;
  }
}
