/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:bloc/bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:meta/meta.dart';
import 'package:mobile_app/gql/queries/system_status.dart';
import 'package:mobile_app/gql/types/lninfo.dart';

enum NodeInfoEventType {
  initial,
  startLoading,
  finishLoading,
  failLoading,
}

class NodeInfoState {
  final NodeInfoEventType type;
  final bool isLoading;
  final String error;
  final LnInfoType info;

  const NodeInfoState({
    @required this.type,
    @required this.isLoading,
    @required this.error,
    @required this.info,
  });

  factory NodeInfoState.initial() {
    return NodeInfoState(
      type: NodeInfoEventType.initial,
      isLoading: true,
      error: '',
      info: null,
    );
  }

  factory NodeInfoState.loading(
      NodeInfoEventType type, NodeInfoState oldState) {
    return NodeInfoState(
      type: type,
      isLoading: true,
      error: oldState.error,
      info: oldState.info,
    );
  }

  factory NodeInfoState.failure(
      NodeInfoEventType type, NodeInfoState oldState, String error) {
    return NodeInfoState(
      type: type,
      isLoading: false,
      error: error,
      info: oldState.info,
    );
  }

  factory NodeInfoState.success(
      NodeInfoEventType type, NodeInfoState oldState, LnInfoType info) {
    return NodeInfoState(
      type: type,
      isLoading: false,
      error: '',
      info: info,
    );
  }
}

abstract class NodeInfoEvent {}

class LoadNodeInfo extends NodeInfoEvent {
  final bool skipCache;
  LoadNodeInfo(this.skipCache);
}

class NodeInfoBloc extends Bloc<NodeInfoEvent, NodeInfoState> {
  final GraphQLClient _client;
  NodeInfoBloc(this._client, {bool preload = true}) {
    if (preload) loadNodeInfo();
  }

  NodeInfoState get initialState => NodeInfoState.initial();

  loadNodeInfo([skipCache = false]) {
    dispatch(LoadNodeInfo(skipCache));
  }

  @override
  Stream<NodeInfoState> mapEventToState(
      NodeInfoState state, NodeInfoEvent event) async* {
    if (event is LoadNodeInfo) {
      yield NodeInfoState.loading(NodeInfoEventType.startLoading, state);
      yield await _loadNodeInfoImpl(state, event.skipCache);
    }
  }

  Future<NodeInfoState> _loadNodeInfoImpl(
      NodeInfoState state, bool skipCache) async {
    QueryResult result;
    if (skipCache) {
      result = await _client.query(QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly, document: getInfoQuery));
    } else {
      result = await _client.query(QueryOptions(document: getInfoQuery));
    }

    String typename = result.data["lnGetInfo"]["__typename"];
    switch (typename) {
      case "GetInfoSuccess":
        LnInfoType info = LnInfoType(result.data["lnGetInfo"]["lnInfo"]);
        return NodeInfoState.success(
            NodeInfoEventType.finishLoading, state, info);
      case "ServerError":
        var errorMessage = result.data["lnGetInfo"]["errorMessage"];
        return NodeInfoState.failure(
            NodeInfoEventType.failLoading, state, errorMessage);
        break;
      default:
        return NodeInfoState.failure(
            NodeInfoEventType.failLoading, state, "Implement me: $typename");
    }
  }
}
