/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

// Represents a payment using the lighnting network
class LnPayment {
  String paymentHash;
  int value;
  DateTime creationDate;
  List<String> path;
  int fee;
  String paymentPreimage;

  LnPayment(Map<String, dynamic> data) {
    paymentHash = data["paymentHash"] ?? "";
    value = data["value"] ?? 0;
    creationDate =
        DateTime.fromMillisecondsSinceEpoch(data["creationDate"] * 1000 ?? 0);
    path = List<String>.from(data["path"] ?? []);
    fee = data["fee"] ?? 0;
    paymentPreimage = data["paymentPreimage"] ?? "";
  }
}
