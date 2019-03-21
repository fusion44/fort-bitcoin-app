/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:bloc/bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/common/types/lnpeer.dart';
import 'package:mobile_app/connectivity/peer/peer_events.dart';
import 'package:mobile_app/connectivity/peer/peer_state.dart';

String connectPeerMutation = """
mutation ConnectPeerMutation(\$pubkey: String!, \$host: String!, \$perm: Boolean) {
  lnConnectPeer(pubkey: \$pubkey, host: \$host, perm: \$perm) {
    __typename
    ... on ConnectPeerSuccess {
      result
      pubkey
      
    }
    ... on ServerError {
      errorMessage
    }
    ... on ConnectPeerError {
      errorMessage
      pubkey
      host
    }
  }
}
""";

String listPeersQuery = """
{
  lnListPeers {
    __typename
    ... on ListPeersSuccess {
      peers {
        hasChannel
        pubKey
        address
        bytesSent
        bytesRecv
        satSent
        satRecv
        inbound
        pingTime
      }
    }
    ... on ListPeersError {
      errorMessage
    }
    ... on ServerError {
      errorMessage
    }
  }
}
""";

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
