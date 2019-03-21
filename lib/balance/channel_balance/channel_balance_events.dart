/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:mobile_app/common/types/lnchannelbalance.dart';

enum ChannelBalanceEventType {
  initial,
  startLoading,
  finishLoading,
  failLoading,
}

abstract class ChannelBalanceEvent {}

class LoadChannelBalanceEvent extends ChannelBalanceEvent {}

class ChannelBalanceUpdatedEvent extends ChannelBalanceEvent {
  final LnChannelBalance balance;
  final String error;

  ChannelBalanceUpdatedEvent({this.balance, this.error});
}
