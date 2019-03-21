/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:mobile_app/common/types/lnhophint.dart';

class LnInvoice {
  String memo;
  String receipt;
  String rPreimage;
  String rHash;
  int value;
  bool settled;
  DateTime creationDate;
  DateTime settleDate;
  String paymentRequest;
  String descriptionHash;
  int expiry;
  String fallbackAddr;
  int cltvExpiry;
  List<LnHopHint> routeHints = List();
  bool private;
  int addIndex;
  int settleIndex;
  int amtPaid;

  LnInvoice(Map<String, dynamic> data) {
    memo = data["memo"] ?? "";
    receipt = data["receipt"] ?? "";
    rPreimage = data["rPreimage"] ?? "";
    rHash = data["rHash"] ?? "";
    value = data["value"];
    settled = data["settled"];
    creationDate =
        DateTime.fromMillisecondsSinceEpoch(data["creationDate"] * 1000 ?? 0);
    settleDate =
        DateTime.fromMillisecondsSinceEpoch(data["settleDate"] * 1000 ?? 0);
    paymentRequest = data["paymentRequest"] ?? "";
    descriptionHash = data["descriptionHash"] ?? "";
    expiry = data["expiry"];
    fallbackAddr = data["fallbackAddr"] ?? "";
    cltvExpiry = data["cltvExpiry"];
    for (var hint in data["routHints"] ?? List()) {
      routeHints.add(LnHopHint(hint));
    }
    private = data["private"];
    addIndex = data["addIndex"];
    settleIndex = data["settleIndex"];
    amtPaid = data["amtPaid"];
  }
}
