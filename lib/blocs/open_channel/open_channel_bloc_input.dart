/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

class StartOpenChannelInput {
  final String nodePubkey;
  final int localFundingAmount;
  final int pushSat;
  final int targetConf;
  final int satPerByte;
  final bool private;
  final int minHtlcMsat;
  final int remoteCsvDelay;
  final int minConfs;
  final bool spendUnconfirmed;

  StartOpenChannelInput({
    this.nodePubkey,
    this.localFundingAmount,
    this.pushSat,
    this.targetConf,
    this.satPerByte,
    this.private,
    this.minHtlcMsat,
    this.remoteCsvDelay,
    this.minConfs,
    this.spendUnconfirmed,
  });

  Object toJSON() {
    return {
      "nodePubkey": this.nodePubkey,
      "localFundingAmount": this.localFundingAmount,
      "pushSat": this.pushSat,
      "targetConf": this.targetConf,
      "satPerByte": this.satPerByte,
      "private": this.private,
      "minHtlcMsat": this.minHtlcMsat,
      "remoteCsvDelay": this.remoteCsvDelay,
      "minConfs": this.minConfs,
      "spendUnconfirmed": this.spendUnconfirmed
    };
  }
}
