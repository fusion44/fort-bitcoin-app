/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:meta/meta.dart';
import 'package:mobile_app/blocs/channel_balance/channel_balance.dart';
import 'package:mobile_app/gql/types/lnchannelbalance.dart';

class ChannelBalanceState {
  final ChannelBalanceEventType type;
  final bool isLoading;
  final LnChannelBalance balance;
  final String error;

  ChannelBalanceState({
    @required this.type,
    @required this.isLoading,
    @required this.balance,
    this.error,
  });

  factory ChannelBalanceState.initial() {
    return ChannelBalanceState(
      type: ChannelBalanceEventType.initial,
      isLoading: true,
      balance: LnChannelBalance({}),
    );
  }

  factory ChannelBalanceState.success({
    @required LnChannelBalance balance,
  }) {
    return ChannelBalanceState(
      type: ChannelBalanceEventType.finishLoading,
      isLoading: false,
      balance: balance,
    );
  }

  factory ChannelBalanceState.failure({
    @required ChannelBalanceState oldState,
    @required String error,
  }) {
    return ChannelBalanceState(
      type: ChannelBalanceEventType.failLoading,
      isLoading: false,
      balance: oldState.balance,
      error: error,
    );
  }
}
