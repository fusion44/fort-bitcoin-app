/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:meta/meta.dart';
import 'package:mobile_app/common/types/lninfo.dart';
import 'package:mobile_app/connectivity/info/wallet_info.dart';

abstract class WalletInfoEvent {}

class UpdateWalletInfoEvent extends WalletInfoEvent {}

class UpdatePollintervallEvent extends WalletInfoEvent {
  final Duration pollIntervallSeconds;

  // Set pollIntervall to 0 to turn of polling
  UpdatePollintervallEvent({@required this.pollIntervallSeconds});
}

class WalletInfoUpdatedEvent extends WalletInfoEvent {
  final WalletStatus status;
  final LnInfoType info;

  WalletInfoUpdatedEvent({@required this.status, @required this.info});
}
