/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:mobile_app/gql/types/lnroutehint.dart';

class LnPayReq {
  String destination;
  String paymentHash;
  int numSatoshis;
  int timestamp;
  int expiry;
  String description;
  String descriptionHash;
  String fallbackAddr;
  int cltvExpiry;
  List<LnRouteHint> routeHints;

  LnPayReq(Map<String, dynamic> data) {
    destination = data["destination"];
    paymentHash = data["paymentHash"];
    numSatoshis = data["numSatoshis"];
    timestamp = data["timestamp"];
    expiry = data["expiry"];
    description = data["description"];
    descriptionHash = data["descriptionHash"];
    fallbackAddr = data["fallbackAddr"];
    cltvExpiry = data["cltvExpiry"];
    if (data["routeHints"] != null) {
      for (var hint in data["routeHints"]) {
        routeHints.add(LnRouteHint(hint));
      }
    }
  }
}
