/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:bloc/bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:meta/meta.dart';
import 'package:mobile_app/gql/mutations/peers.dart';
import 'package:mobile_app/gql/queries/system_status.dart';
import 'package:mobile_app/gql/types/lnpeer.dart';

enum PeerEventType {
  initial,
  startLoading,
  finishLoading,
  failLoading,
  startConnectPeer,
  finishConnectPeer,
  startDisconnectPeer,
  finishDisconnectPeer,
  failDisconnecting,
}

class PeerState {
  final PeerEventType type;
  final bool isLoading;
  final bool isConnecting;
  final String error;
  final List<LnPeer> peers;

  const PeerState({
    @required this.type,
    @required this.isLoading,
    @required this.isConnecting,
    @required this.error,
    @required this.peers,
  });

  factory PeerState.initial() {
    return PeerState(
      type: PeerEventType.initial,
      isLoading: true,
      isConnecting: false,
      error: '',
      peers: [],
    );
  }

  factory PeerState.loading(PeerEventType type, PeerState oldState) {
    return PeerState(
      type: type,
      isLoading: true,
      isConnecting: oldState.isConnecting,
      error: oldState.error,
      peers: oldState.peers,
    );
  }

  factory PeerState.startConnectPeer(PeerState oldState) {
    return PeerState(
      type: PeerEventType.startConnectPeer,
      isLoading: oldState.isLoading,
      isConnecting: true,
      error: oldState.error,
      peers: oldState.peers,
    );
  }

  factory PeerState.finishConnectPeer(PeerState oldState) {
    return PeerState(
      type: PeerEventType.finishConnectPeer,
      isLoading: oldState.isLoading,
      isConnecting: false,
      error: oldState.error,
      peers: oldState.peers,
    );
  }

  factory PeerState.failure(
      PeerEventType type, PeerState oldState, String error) {
    return PeerState(
      type: type,
      isLoading: oldState.isLoading,
      isConnecting: oldState.isConnecting,
      error: error,
      peers: oldState.peers,
    );
  }

  factory PeerState.success(
      PeerEventType type, PeerState oldState, List<LnPeer> peers) {
    return PeerState(
      type: type,
      isLoading: false,
      isConnecting: oldState.isConnecting,
      error: '',
      peers: peers,
    );
  }
}

abstract class PeerEvent {}

class LoadPeers extends PeerEvent {
  final bool skipCache;
  LoadPeers(this.skipCache);
}

class ConnectPeer extends PeerEvent {
  final String nodeId;
  final String nodeHost;
  final bool permanent;

  ConnectPeer(this.nodeId, this.nodeHost, this.permanent);
}

class DisconnectPeer extends PeerEvent {}

class PeerBloc extends Bloc<PeerEvent, PeerState> {
  bool _isConnecting = false;

  final GraphQLClient _client;
  PeerBloc(this._client, {bool preload = true}) {
    if (preload) loadPeers();
  }

  PeerState get initialState => PeerState.initial();

  loadPeers([skipCache = false]) {
    dispatch(LoadPeers(skipCache));
  }

  connectPeer(String nodeId, String nodeHost, [bool permanent = false]) {
    if (_isConnecting) return;

    dispatch(ConnectPeer(nodeId, nodeHost, permanent));
  }

  disconnectPeer() {
    dispatch(DisconnectPeer());
  }

  @override
  Stream<PeerState> mapEventToState(PeerState state, PeerEvent event) async* {
    if (event is LoadPeers) {
      yield PeerState.loading(PeerEventType.startLoading, state);
      yield await _loadPeersImpl(state, event.skipCache);
    }
    if (event is ConnectPeer) {
      yield PeerState.startConnectPeer(state);
      yield await _connectPeerImpl(
          state, event.nodeId, event.nodeHost, event.permanent);
    }
    if (event is DisconnectPeer) {}
  }

  Future<PeerState> _loadPeersImpl(PeerState state, bool skipCache) async {
    QueryResult result;
    if (skipCache) {
      result = await _client.query(QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly, document: listPeersQuery));
    } else {
      result = await _client.query(QueryOptions(document: listPeersQuery));
    }

    String typename = result.data["lnListPeers"]["__typename"];
    switch (typename) {
      case "ListPeersSuccess":
        List<LnPeer> peers = [];
        for (Map peer in result.data["lnListPeers"]["peers"]) {
          peers.add(LnPeer(peer));
        }
        return PeerState.success(PeerEventType.finishLoading, state, peers);
      case "ListPeersError":
      case "ServerError":
        var errorMessage = result.data["lnListPeers"]["errorMessage"];
        return PeerState.failure(
            PeerEventType.failLoading, state, errorMessage);
        break;
      default:
        return PeerState.failure(
            PeerEventType.failLoading, state, "Implement me: $typename");
    }
  }

  Future<PeerState> _connectPeerImpl(
      PeerState state, String nodeId, String nodeHost,
      [bool permanent = false]) async {
    _isConnecting = true;

    var v = {"pubkey": nodeId, "host": nodeHost, "perm": permanent};
    try {
      QueryResult result = await _client.query(QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: connectPeerMutation,
          variables: v));

      _isConnecting = false;

      String typename = result.data["lnConnectPeer"]["__typename"];
      switch (typename) {
        case "ConnectPeerSuccess":
          return PeerState.finishConnectPeer(state);
          break;
        case "ServerError":
        case "ConnectPeerError":
          return PeerState.failure(PeerEventType.finishConnectPeer, state,
              result.data["lnConnectPeer"]["errorMessage"]);
          break;
        default:
          return PeerState.failure(
              PeerEventType.finishConnectPeer, state, "Implement me $typename");
      }
    } catch (err) {
      _isConnecting = false;
      return PeerState.failure(
          PeerEventType.finishConnectPeer, state, err.toString());
    }
  }
}
