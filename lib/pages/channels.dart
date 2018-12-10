/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/blocs/channels_bloc.dart';
import 'package:mobile_app/blocs/peers_bloc.dart';
import 'package:mobile_app/widgets/channel_display.dart';

class ChannelsPage extends StatelessWidget {
  final bool _testnet;
  ChannelsPage([this._testnet = false]);

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
                channelList.add(ChannelDisplay(
                    chan, peerState.getPeerById(chan.remotePubkey)));
              }

              return RefreshIndicator(
                  onRefresh: () async {
                    channelBloc.loadChannels(true);
                  },
                  child: Column(
                    children: <Widget>[
                      channelState.isLoading
                          ? LinearProgressIndicator()
                          : Container(),
                      Expanded(
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: channelList,
                        ),
                      ),
                    ],
                  ));
            });
      },
    );
  }
}
