/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:mobile_app/gql/types/lnhop.dart';

class LnRoute {
  int totalTimeLock;
  int totalFees;
  int totalAmt;
  List<LnHop> hops = List<LnHop>();
  int totalFeesMsat;
  int totalAmtMsat;

  LnRoute(Map<String, dynamic> data) {
    totalTimeLock = data["totalTimeLock"];
    totalFees = data["totalFees"];
    totalAmt = data["totalAmt"];
    if (data["hops"] != null) {
      for (var hop in data["hops"]) {
        hops.add(LnHop(hop));
      }
    }
    totalFeesMsat = data["totalFeesMsat"];
    totalAmtMsat = data["totalAmtMsat"];
  }
}
