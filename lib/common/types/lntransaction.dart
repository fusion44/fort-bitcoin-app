/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

// Represents an onchain transction
class LnTransaction {
  int amount;
  DateTime timeStamp;
  List<String> destAddresses = [];
  int totalFees;

  LnTransaction(Map<String, dynamic> data) {
    amount = data["amount"] ?? 0;
    timeStamp =
        DateTime.fromMillisecondsSinceEpoch(data["timeStamp"] * 1000 ?? 0);
    totalFees = data["totalFees"] ?? 0;
    for (String addr in data["destAddresses"] ?? []) {
      destAddresses.add(addr);
    }
  }
}
