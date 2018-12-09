/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

class LnChannelPoint {
  String fundingTxId;
  int outputIndex;

  LnChannelPoint(this.fundingTxId, this.outputIndex);

  LnChannelPoint.fromEncodedString(String channelPoint) {
    List<String> split = channelPoint.split(":");
    this.fundingTxId = split[0];
    this.outputIndex = int.tryParse(split[1]);
  }

  toJSON() {
    return {
      "fundingTxidStr": this.fundingTxId,
      "outputIndex": this.outputIndex
    };
  }
}
