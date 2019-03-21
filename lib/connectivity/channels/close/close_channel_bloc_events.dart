/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:meta/meta.dart';
import 'package:mobile_app/connectivity/channels/close/close_channel.dart';

enum CloseChannelEventType {
  // Subscriber subscribes to the Bloc
  initial,
  // For the brief moment when the request to the server
  // is initiated and we're waiting for the channel pending update
  start,
  // Channel close is initiated.
  // We receive the TxID and the output index
  channelCloseIsPending,
  // A new confirmation was registered
  channelConfUpdate,
  // Channel is closed, we have all
  // required confirmations
  channelIsClosed,
  // Something went wrong during the process
  failClosing,
}

abstract class CloseChannelEvent {}

/// Asks the server to create a new channel with the given input.
class StartCloseChannelEvent extends CloseChannelEvent {
  final StartCloseChannelInput input;

  StartCloseChannelEvent(this.input);
}

/// First event emitted when the new channel is
/// created and now is pending
class CloseChannelPendingEvent extends CloseChannelEvent {
  final String txid;

  CloseChannelPendingEvent({@required this.txid});
}

/// Emitted when we've received new confirmation data
class ChannelConfirmationEvent extends CloseChannelEvent {
  final String blockSha;
  final int blockHeight;
  final int numConfsLeft;

  ChannelConfirmationEvent(
      {@required this.blockSha,
      @required this.blockHeight,
      @required this.numConfsLeft});
}

/// Final event emitted when the channel is successfully closed
class ChannelIsClosedEvent extends CloseChannelEvent {
  final String txid;
  final bool success;

  ChannelIsClosedEvent({@required this.txid, @required this.success});
}

/// Emitted on error
class CloseChannelErrorEvent extends CloseChannelEvent {
  final String error;

  CloseChannelErrorEvent({@required this.error});
}

class ResetCloseChannelEvent extends CloseChannelEvent {}
