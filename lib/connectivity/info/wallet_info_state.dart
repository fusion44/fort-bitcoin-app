/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:meta/meta.dart';
import 'package:mobile_app/common/types/lninfo.dart';

enum WalletStatus { notInitialized, notRunning, locked, ready, unknown }

class WalletInfoState {
  final bool loading;
  final WalletStatus status;
  final LnInfoType info;
  final bool autoupdate;
  final Duration pollIntervall;

  WalletInfoState({
    @required this.loading,
    @required this.status,
    @required this.info,
    this.autoupdate = false,
    this.pollIntervall,
  });

  factory WalletInfoState.initial() {
    return WalletInfoState(
      loading: true,
      status: WalletStatus.unknown,
      info: LnInfoType({}),
    );
  }
}
