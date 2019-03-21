/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:bloc/bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:meta/meta.dart';
import 'package:mobile_app/common/types/lnchannel.dart';

String listChannelsQuery = """
{
  lnListChannels {
    __typename
    ... on ListChannelsSuccess {
      channels {
        active
        remotePubkey
        channelPoint
        chanId
        capacity
        localBalance
        remoteBalance
        commitFee
        commitWeight
        feePerKw
        unsettledBalance
        totalSatoshisSent
        totalSatoshisReceived
        numUpdates
        csvDelay
        private
        pendingHtlcs {
          incoming
          amount
          hashLock
          expirationHeight
        }
      }
    }
    ... on ListChannelsError {
      errorMessage
    }
    ... on ServerError {
      errorMessage
    }
  }
}
""";

enum ChannelEventType {
  initial,
  startLoading,
  finishLoading,
  failLoading,
  startOpenChannel,
  finishOpenChannel,
  startCloseChannel,
  finishCloseChannel,
}

class ChannelState {
  final ChannelEventType type;
  final bool isLoading;
  final bool isOpening;
  final String error;
  final List<LnChannel> channels;

  const ChannelState({
    @required this.type,
    @required this.isLoading,
    @required this.isOpening,
    @required this.error,
    @required this.channels,
  });

  getChannelById(String chanId) {
    for (LnChannel channel in channels) {
      if (channel.chanId == chanId) return channel;
    }
    return null;
  }

  factory ChannelState.initial() {
    return ChannelState(
      type: ChannelEventType.initial,
      isLoading: true,
      isOpening: false,
      error: '',
      channels: [],
    );
  }

  factory ChannelState.loading(ChannelEventType type, ChannelState oldState) {
    return ChannelState(
      type: type,
      isLoading: true,
      isOpening: oldState.isOpening,
      error: oldState.error,
      channels: oldState.channels,
    );
  }

  factory ChannelState.startOpenChannel(ChannelState oldState) {
    return ChannelState(
      type: ChannelEventType.startOpenChannel,
      isLoading: oldState.isLoading,
      isOpening: true,
      error: oldState.error,
      channels: oldState.channels,
    );
  }

  factory ChannelState.finishOpenChannel(ChannelState oldState) {
    return ChannelState(
      type: ChannelEventType.finishOpenChannel,
      isLoading: oldState.isLoading,
      isOpening: false,
      error: oldState.error,
      channels: oldState.channels,
    );
  }

  factory ChannelState.failure(
      ChannelEventType type, ChannelState oldState, String error) {
    return ChannelState(
      type: type,
      isLoading: oldState.isLoading,
      isOpening: oldState.isOpening,
      error: error,
      channels: oldState.channels,
    );
  }

  factory ChannelState.success(
      ChannelEventType type, ChannelState oldState, List<LnChannel> channels) {
    return ChannelState(
      type: type,
      isLoading: false,
      isOpening: oldState.isOpening,
      error: '',
      channels: channels,
    );
  }
}

abstract class ChannelEvent {}

class LoadChannels extends ChannelEvent {
  final bool skipCache;
  LoadChannels(this.skipCache);
}

class ConnectChannel extends ChannelEvent {
  final String nodeId;
  final String nodeHost;
  final bool permanent;

  ConnectChannel(this.nodeId, this.nodeHost, this.permanent);
}

class DisconnectChannel extends ChannelEvent {}

class ChannelBloc extends Bloc<ChannelEvent, ChannelState> {
  bool _isConnecting = false;

  final GraphQLClient _client;
  ChannelBloc(this._client, {bool preload = true}) {
    if (preload) loadChannels();
  }

  ChannelState get initialState => ChannelState.initial();

  loadChannels([skipCache = false]) {
    dispatch(LoadChannels(skipCache));
  }

  connectChannel(String nodeId, String nodeHost, [bool permanent = false]) {
    if (_isConnecting) return;

    dispatch(ConnectChannel(nodeId, nodeHost, permanent));
  }

  disconnectChannel() {
    dispatch(DisconnectChannel());
  }

  @override
  Stream<ChannelState> mapEventToState(
      ChannelState state, ChannelEvent event) async* {
    if (event is LoadChannels) {
      yield ChannelState.loading(ChannelEventType.startLoading, state);
      yield await _loadChannelsImpl(state, event.skipCache);
    }
    if (event is ConnectChannel) {
      yield ChannelState.startOpenChannel(state);
      yield await _connectChannelImpl(
          state, event.nodeId, event.nodeHost, event.permanent);
    }
    if (event is DisconnectChannel) {}
  }

  Future<ChannelState> _loadChannelsImpl(
      ChannelState state, bool skipCache) async {
    QueryResult result;
    if (skipCache) {
      result = await _client.query(QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly, document: listChannelsQuery));
    } else {
      result = await _client.query(QueryOptions(document: listChannelsQuery));
    }

    String typename = result.data["lnListChannels"]["__typename"];
    switch (typename) {
      case "ListChannelsSuccess":
        List<LnChannel> channels = [];
        for (Map channel in result.data["lnListChannels"]["channels"]) {
          channels.add(LnChannel(channel));
        }
        return ChannelState.success(
            ChannelEventType.finishLoading, state, channels);
      case "ListChannelsError":
      case "ServerError":
        var errorMessage = result.data["lnListChannels"]["errorMessage"];
        return ChannelState.failure(
            ChannelEventType.failLoading, state, errorMessage);
        break;
      default:
        return ChannelState.failure(
            ChannelEventType.failLoading, state, "Implement me: $typename");
    }
  }

  Future<ChannelState> _connectChannelImpl(
      ChannelState state, String nodeId, String nodeHost,
      [bool permanent = false]) async {
    _isConnecting = true;

    var v = {"pubkey": nodeId, "host": nodeHost, "perm": permanent};
    try {
      QueryResult result = await _client.query(QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: "connectChannelMutation",
          variables: v));

      _isConnecting = false;

      String typename = result.data["lnConnectChannel"]["__typename"];
      switch (typename) {
        case "ConnectChannelSuccess":
          return ChannelState.finishOpenChannel(state);
          break;
        case "ServerError":
        case "ConnectChannelError":
          return ChannelState.failure(ChannelEventType.finishOpenChannel, state,
              result.data["lnConnectChannel"]["errorMessage"]);
          break;
        default:
          return ChannelState.failure(ChannelEventType.finishOpenChannel, state,
              "Implement me $typename");
      }
    } catch (err) {
      _isConnecting = false;
      return ChannelState.failure(
          ChannelEventType.finishOpenChannel, state, err.toString());
    }
  }
}
