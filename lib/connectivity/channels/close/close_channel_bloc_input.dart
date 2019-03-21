/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:mobile_app/common/types/lnchannelpoint.dart';

class StartCloseChannelInput {
  final LnChannelPoint channelPoint;
  final bool force;
  final int targetConf;
  final int satPerByte;

  StartCloseChannelInput({
    this.channelPoint,
    this.force,
    this.targetConf,
    this.satPerByte,
  });

  Object toJSON() {
    return {
      "fundingTxid": this.channelPoint.fundingTxId,
      "outputIndex": this.channelPoint.outputIndex,
      "force": this.force,
      "targetConf": this.targetConf,
      "satPerByte": this.satPerByte,
    };
  }
}
