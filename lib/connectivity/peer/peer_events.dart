/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
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
