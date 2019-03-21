/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/common/widgets/channel_display.dart';
import 'package:mobile_app/connectivity/channels/channels_bloc.dart';
import 'package:mobile_app/connectivity/peer/peer.dart';

class ChannelPage extends StatefulWidget {
  ChannelPage();

  @override
  _ChannelPageState createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
  }

  @override
  Widget build(BuildContext context) {
    ChannelBloc channelBloc = BlocProvider.of<ChannelBloc>(context);
    PeerBloc peerBloc = BlocProvider.of<PeerBloc>(context);
    return BlocBuilder<ChannelEvent, ChannelState>(
      bloc: channelBloc,
      builder: (
        BuildContext context,
        ChannelState channelState,
      ) {
        return BlocBuilder<PeerEvent, PeerState>(
          bloc: peerBloc,
          builder: (
            BuildContext context,
            PeerState peerState,
          ) {
            List<Widget> channelList = [];
            for (var chan in channelState.channels) {
              channelList.add(ChannelDisplayWidget(
                  chan, peerState.getPeerById(chan.remotePubkey)));
            }

            if (channelState.type == ChannelEventType.finishLoading ||
                channelState.type == ChannelEventType.failLoading) {
              _refreshCompleter?.complete();
              _refreshCompleter = Completer<void>();
            }

            return RefreshIndicator(
              onRefresh: () async {
                channelBloc.loadChannels(true);
                return _refreshCompleter.future;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: channelList,
              ),
            );
          },
        );
      },
    );
  }
}
