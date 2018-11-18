/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:meta/meta.dart';
import 'package:mobile_app/blocs/open_channel/open_channel_bloc_input.dart';

enum OpenChannelEventType {
  // Subscriber subscribes to the Bloc
  initial,
  // For the brief moment when the request to the server
  // is initiated and we're waiting for the channel pending update
  start,
  // A new channel is initiated.
  // We receive the TxID and the output index
  channelIsPending,
  // A new confirmation was registered
  channelConfUpdate,
  // Channel is open and usable, we have all
  // required confirmations
  channelIsOpen,
  // Something went wrong during the process
  failOpening,
}

abstract class OpenChannelEvent {}

/// Asks the server to create a new channel with the given input.
class StartOpenChannelEvent extends OpenChannelEvent {
  final StartOpenChannelInput input;

  StartOpenChannelEvent(this.input);
}

/// First event emitted when the new channel is
/// created and now is pending
class ChannelPendingEvent extends OpenChannelEvent {
  final String txid;
  final int outputIndex;

  ChannelPendingEvent({@required this.txid, @required this.outputIndex});
}

/// Emitted when we've received new confirmation data
class ChannelConfirmationEvent extends OpenChannelEvent {
  final String blockSha;
  final int blockHeight;
  final int numConfsLeft;

  ChannelConfirmationEvent(
      {@required this.blockSha,
      @required this.blockHeight,
      @required this.numConfsLeft});
}

/// Final event emitted when the channel is successfully opened
/// and is fully usable
class ChannelIsOpenEvent extends OpenChannelEvent {
  final String txid;
  final int outputIndex;

  ChannelIsOpenEvent({@required this.txid, @required this.outputIndex});
}

/// Emitted on error
class OpenChannelErrorEvent extends OpenChannelEvent {
  final String error;

  OpenChannelErrorEvent({@required this.error});
}

class ResetOpenChannelEvent extends OpenChannelEvent {}
