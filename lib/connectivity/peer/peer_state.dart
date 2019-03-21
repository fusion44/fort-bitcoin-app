/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:meta/meta.dart';
import 'package:mobile_app/common/types/lnpeer.dart';
import 'package:mobile_app/connectivity/peer/peer_events.dart';

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

  LnPeer getPeerById(String pubKey) {
    for (LnPeer peer in peers) {
      if (peer.pubKey == pubKey) return peer;
    }
    return null;
  }

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
