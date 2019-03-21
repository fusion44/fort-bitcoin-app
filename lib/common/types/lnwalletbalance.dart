/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

class LnWalletBalance {
  int totalBalance;
  int confirmedBalance;
  int unconfirmedBalance;

  LnWalletBalance(Map<String, dynamic> data) {
    totalBalance = data["totalBalance"] ?? 0;
    confirmedBalance = data["confirmedBalance"] ?? 0;
    unconfirmedBalance = data["unconfirmedBalance"] ?? 0;
  }
}
