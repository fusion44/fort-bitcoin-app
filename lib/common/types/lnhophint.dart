/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

class LnHopHint {
  // The public key of the node at the start of the channel.
  String nodeId;

  //The unique identifier of the channel.
  int chanId;

  // The base fee of the channel denominated in millisatoshis.
  int feeBaseMsat;

  //The fee rate of the channel for sending one satoshi across it denominated in millionths of a satoshi.
  int feeProportionalMillionths;

  // The time-lock delta of the channel.
  int cltvExpiryDelta;

  LnHopHint(hopHint) {
    nodeId = hopHint["nodeId"];
    chanId = hopHint["chanId"];
    feeBaseMsat = hopHint["feeBaseMsat"];
    feeProportionalMillionths = hopHint["feeProportionalMillionths"];
    cltvExpiryDelta = hopHint["cltvExpiryDelta"];
  }
}
