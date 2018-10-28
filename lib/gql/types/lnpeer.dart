/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

class LnPeer {
  String pubKey;
  String address;
  int bytesSent;
  int bytesRecv;
  int satSent;
  int satRecv;
  bool inbound;
  int pingTime;
  bool hasChannel;

  LnPeer(Map<String, dynamic> data) {
    pubKey = data["pubKey"];
    address = data["address"];
    bytesSent = data["bytesSent"];
    bytesRecv = data["bytesRecv"];
    satSent = data["satSent"];
    satRecv = data["satRecv"];
    inbound = data["inbound"];
    pingTime = data["pingTime"];
    hasChannel = data["hasChannel"];
  }
}
