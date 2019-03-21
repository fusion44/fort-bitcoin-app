/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:meta/meta.dart';
import 'package:mobile_app/connectivity/channels/close/close_channel.dart';

class ChannelCloseState {
  final CloseChannelEventType type;
  final bool isWorking;
  final String error;
  final String txid;
  final bool success;

  const ChannelCloseState({
    @required this.type,
    @required this.isWorking,
    @required this.error,
    @required this.txid,
    @required this.success,
  });

  factory ChannelCloseState.initial() {
    return ChannelCloseState(
      type: CloseChannelEventType.initial,
      isWorking: false,
      error: "",
      txid: null,
      success: null,
    );
  }

  factory ChannelCloseState.start() {
    return ChannelCloseState(
      type: CloseChannelEventType.start,
      isWorking: true,
      error: "",
      txid: null,
      success: null,
    );
  }

  factory ChannelCloseState.channelCloseIsPending(String txid) {
    return ChannelCloseState(
      type: CloseChannelEventType.channelCloseIsPending,
      isWorking: true,
      error: "",
      txid: txid,
      success: null,
    );
  }

  factory ChannelCloseState.channelIsClosed(
      String txid, bool success, ChannelCloseState oldState) {
    return ChannelCloseState(
      type: CloseChannelEventType.channelIsClosed,
      isWorking: false,
      error: '',
      txid: txid,
      success: success,
    );
  }

  factory ChannelCloseState.failure(
    String error,
    ChannelCloseState oldState,
  ) {
    return ChannelCloseState(
      type: CloseChannelEventType.failClosing,
      isWorking: false,
      error: error,
      txid: oldState.txid,
      success: oldState.success,
    );
  }
}
