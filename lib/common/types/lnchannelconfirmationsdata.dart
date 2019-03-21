/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

class LnChannelConfirmationsData {
  final String blockSHA;
  final int blockHeight;
  final int numConfsLeft;

  LnChannelConfirmationsData(
    this.blockSHA,
    this.blockHeight,
    this.numConfsLeft,
  );
}
