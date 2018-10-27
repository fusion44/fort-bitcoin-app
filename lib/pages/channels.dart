/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/blocs/channels_bloc.dart';
import 'package:mobile_app/widgets/channel_display.dart';

class ChannelsPage extends StatelessWidget {
  final bool _testnet;
  final ChannelBloc _channelBloc;
  ChannelsPage(this._channelBloc, [this._testnet = false]);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelEvent, ChannelState>(
      bloc: _channelBloc,
      builder: (
        BuildContext context,
        ChannelState channelState,
      ) {
        List<Widget> channelList = [];
        for (var chan in channelState.channels) {
          channelList.add(ChannelDisplay(chan));
        }

        return RefreshIndicator(
            onRefresh: () async {
              _channelBloc.loadChannels(true);
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
      },
    );
  }
}
