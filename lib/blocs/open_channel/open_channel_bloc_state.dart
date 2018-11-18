/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:meta/meta.dart';
import 'package:mobile_app/blocs/open_channel/open_channel_bloc_events.dart';
import 'package:mobile_app/gql/types/lnchannelconfirmationsdata.dart';
import 'package:mobile_app/gql/types/lnchannelpoint.dart';

class ChannelOpenState {
  final OpenChannelEventType type;
  final bool isWorking;
  final String error;
  final LnChannelPoint point;
  final LnChannelConfirmationsData confData;

  const ChannelOpenState({
    @required this.type,
    @required this.isWorking,
    @required this.error,
    @required this.point,
    @required this.confData,
  });

  factory ChannelOpenState.initial() {
    return ChannelOpenState(
      type: OpenChannelEventType.initial,
      isWorking: false,
      error: "",
      point: null,
      confData: null,
    );
  }

  factory ChannelOpenState.start() {
    return ChannelOpenState(
      type: OpenChannelEventType.start,
      isWorking: true,
      error: "",
      point: null,
      confData: null,
    );
  }

  factory ChannelOpenState.channelIsPending(LnChannelPoint point) {
    return ChannelOpenState(
      type: OpenChannelEventType.channelIsPending,
      isWorking: true,
      error: "",
      point: point,
      confData: null,
    );
  }

  factory ChannelOpenState.confUpdate(
      LnChannelConfirmationsData data, ChannelOpenState oldState) {
    return ChannelOpenState(
      type: OpenChannelEventType.channelConfUpdate,
      isWorking: true,
      error: "",
      point: oldState.point,
      confData: data,
    );
  }

  factory ChannelOpenState.channelIsOpen(
      LnChannelPoint update, ChannelOpenState oldState) {
    return ChannelOpenState(
      type: OpenChannelEventType.channelIsOpen,
      isWorking: false,
      error: '',
      point: oldState.point,
      confData: null,
    );
  }

  factory ChannelOpenState.failure(
    String error,
    ChannelOpenState oldState,
  ) {
    return ChannelOpenState(
      type: OpenChannelEventType.failOpening,
      isWorking: false,
      error: error,
      point: oldState.point,
      confData: oldState.confData,
    );
  }
}
