/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/authhelper.dart';
import 'package:mobile_app/blocs/close_channel/close_channel_bloc_events.dart';
import 'package:mobile_app/blocs/close_channel/close_channel_bloc_input.dart';
import 'package:mobile_app/blocs/close_channel/close_channel_bloc_state.dart';
import 'package:mobile_app/gql/mutations/channels.dart';
import '../../config.dart' as config;

class CloseChannelBloc extends Bloc<CloseChannelEvent, ChannelCloseState> {
  SocketClient _socketClient;
  StreamSubscription<SubscriptionData> _subscription;

  ChannelCloseState get initialState => ChannelCloseState.initial();

  @override
  void dispose() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
    super.dispose();
  }

  startCloseChannel(StartCloseChannelInput input) {
    dispatch(StartCloseChannelEvent(input));
  }

  reset() {
    dispatch(ResetCloseChannelEvent());
  }

  @override
  Stream<ChannelCloseState> mapEventToState(
      ChannelCloseState state, CloseChannelEvent event) async* {
    if (event is StartCloseChannelEvent) {
      yield ChannelCloseState.start();
      _closeChannelImpl(event.input);
    } else if (event is ChannelIsClosedEvent) {
      yield ChannelCloseState.channelIsClosed(event.txid, event.success, state);
    } else if (event is CloseChannelPendingEvent) {
      yield ChannelCloseState.channelCloseIsPending(event.txid);
    } else if (event is CloseChannelErrorEvent) {
      yield ChannelCloseState.failure(event.error, state);
    } else if (event is ResetCloseChannelEvent) {
      _subscription.cancel();
      _subscription = null;
      _socketClient = null;
      yield ChannelCloseState.initial();
    }
  }

  void _closeChannelImpl(StartCloseChannelInput input) async {
    _socketClient = await SocketClient.connect(config.endPointWS, headers: {
      'content-type': 'application/json',
      'Authorization': 'JWT ${AuthHelper().user.token}'
    });

    _subscription = _socketClient
        .subscribe(SubscriptionRequest(
            "CloseChannelSub", closeChannelSubscription, input.toJSON()))
        .listen(
      (data) {
        if (data.data == null) {
          dispatch(
            CloseChannelErrorEvent(error: data.errors[0]["message"]),
          );
        } else {
          var _subData = data.data["closeChannelSubscription"];
          String typename = _subData["__typename"];

          switch (typename) {
            case "ChannelClosePendingUpdate":
              // Channel is now pending and waiting for required num of confirmations
              dispatch(CloseChannelPendingEvent(txid: _subData["txid"]));
              break;
            case "ChannelCloseUpdate":
              // Channel is closed, wrap up
              dispatch(
                ChannelIsClosedEvent(
                  txid: _subData["closingTxid"],
                  success: _subData["success"],
                ),
              );
              break;
            case "CloseChannelError":
            case "ServerError":
              var errorMessage =
                  _subData["errorMessage"] ?? "No errorMessge delivered";

              print("got error: $errorMessage");
              dispatch(CloseChannelErrorEvent(error: errorMessage));
              break;
            default:
              dispatch(
                  CloseChannelErrorEvent(error: "Implement me: $typename"));
          }
        }
      },
    );
  }
}
