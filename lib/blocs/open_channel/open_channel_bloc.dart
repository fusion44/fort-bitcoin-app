/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/blocs/open_channel/open_channel_bloc_events.dart';
import 'package:mobile_app/blocs/open_channel/open_channel_bloc_input.dart';
import 'package:mobile_app/blocs/open_channel/open_channel_bloc_state.dart';
import 'package:mobile_app/gql/mutations/channels.dart';
import 'package:mobile_app/gql/types/lnchannelconfirmationsdata.dart';
import 'package:mobile_app/gql/types/lnchannelpoint.dart';
import '../../config.dart' as config;

class OpenChannelBloc extends Bloc<OpenChannelEvent, ChannelOpenState> {
  final String _token;
  SocketClient _socketClient;
  StreamSubscription<SubscriptionData> _subscription;

  OpenChannelBloc(this._token);

  ChannelOpenState get initialState => ChannelOpenState.initial();
  @override
  void dispose() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
    super.dispose();
  }

  startOpenChannel(StartOpenChannelInput input) {
    dispatch(StartOpenChannelEvent(input));
  }

  reset() {
    dispatch(ResetOpenChannelEvent());
  }

  @override
  Stream<ChannelOpenState> mapEventToState(
      ChannelOpenState state, OpenChannelEvent event) async* {
    if (event is StartOpenChannelEvent) {
      // Start the open channel process by establishing the
      // connection to the server and broadcast the initial state
      // to listeners
      yield ChannelOpenState.start();
      _openChannelImpl(event.input);
    } else if (event is ChannelIsOpenEvent) {
      yield ChannelOpenState.channelIsOpen(
          LnChannelPoint(event.txid, event.outputIndex), state);
    } else if (event is ChannelPendingEvent) {
      yield ChannelOpenState.channelIsPending(
          LnChannelPoint(event.txid, event.outputIndex));
    } else if (event is ChannelConfirmationEvent) {
      yield ChannelOpenState.confUpdate(
          LnChannelConfirmationsData(
              event.blockSha, event.blockHeight, event.numConfsLeft),
          state);
    } else if (event is ChannelIsOpenEvent) {
      yield ChannelOpenState.channelIsOpen(
          LnChannelPoint(event.txid, event.outputIndex), state);
    } else if (event is OpenChannelErrorEvent) {
      yield ChannelOpenState.failure(event.error, state);
    } else if (event is ResetOpenChannelEvent) {
      _subscription.cancel();
      _subscription = null;
      _socketClient = null;
      yield ChannelOpenState.initial();
    }
  }

  void _openChannelImpl(StartOpenChannelInput input) async {
    _socketClient = await SocketClient.connect(config.endPointWS, headers: {
      "content-type": "application/json",
      "Authorization": "JWT $_token"
    });

    _subscription = _socketClient
        .subscribe(SubscriptionRequest(
            "OpenChannelSub", openChannelSubscription, input.toJSON()))
        .listen((data) {
      if (data.data == null) {
        dispatch(
          OpenChannelErrorEvent(error: data.errors[0]["message"]),
        );
      } else {
        var _subData = data.data["openChannelSubscription"];
        String typename = _subData["__typename"];

        switch (typename) {
          case "ChannelPendingUpdate":
            // Channel is now pending and waiting for required num of confirmations
            dispatch(
              ChannelPendingEvent(
                txid: _subData["channelPoint"]["fundingTxid"],
                outputIndex: _subData["channelPoint"]["outputIndex"],
              ),
            );
            break;
          case "ChannelConfirmationUpdate":
            // Confirmation state is updated
            dispatch(
              ChannelConfirmationEvent(
                blockSha: _subData["blockSha"],
                blockHeight: _subData["blockHeight"],
                numConfsLeft: _subData["numConfsLeft"],
              ),
            );
            break;
          case "ChannelOpenUpdate":
            // Channel is open and usable, finish.
            dispatch(
              ChannelIsOpenEvent(
                txid: _subData["channelPoint"]["fundingTxid"],
                outputIndex: _subData["channelPoint"]["outputIndex"],
              ),
            );
            break;
          case "OpenChannelError":
          case "ServerError":
            var errorMessage =
                _subData["errorMessage"] ?? "No errorMessge delivered";

            print("got error: $errorMessage");
            dispatch(OpenChannelErrorEvent(error: errorMessage));
            break;
          default:
            dispatch(OpenChannelErrorEvent(error: "Implement me: $typename"));
        }
      }
    });
  }
}
