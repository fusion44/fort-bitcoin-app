/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:mobile_app/gql/types/lnhtlc.dart';

class LnChannel {
  bool active;
  String remotePubkey;
  String channelPoint;
  String chanId;
  int capacity;
  int localBalance;
  int remoteBalance;
  int commitFee;
  int commitWeight;
  int feePerKw;
  int unsettledBalance;
  int totalSatoshisSent;
  int totalSatoshisReceived;
  int numUpdates;
  List<LnHTLC> pendingHTLCs = [];
  int csvDelay;
  bool private;

  LnChannel(Map<String, dynamic> data) {
    active = data["active"];
    remotePubkey = data["remotePubkey"];
    channelPoint = data["channelPoint"];
    chanId = data["chanId"];
    capacity = data["capacity"];
    localBalance = data["localBalance"];
    remoteBalance = data["remoteBalance"];
    commitFee = data["commitFee"];
    commitWeight = data["commitWeight"];
    feePerKw = data["feePerKw"];
    unsettledBalance = data["unsettledBalance"];
    totalSatoshisSent = data["totalSatoshisSent"];
    totalSatoshisReceived = data["totalSatoshisReceived"];
    numUpdates = data["numUpdates"];
    if (data.containsKey("pendingHTLCs")) {
      for (var htlc in data["pendingHTLCs"]) {
        pendingHTLCs.add(LnHTLC(htlc));
      }
    }
    csvDelay = data["csvDelay"];
    private = data["private"];
  }
}
