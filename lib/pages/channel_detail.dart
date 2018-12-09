import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/channels_bloc.dart';
import 'package:mobile_app/blocs/peers_bloc.dart';
import 'package:mobile_app/blocs/close_channel/close_channel_bloc.dart';
import 'package:mobile_app/gql/types/lnchannel.dart';
import 'package:mobile_app/gql/types/lnpeer.dart';
import 'package:mobile_app/pages/close_channel.dart';
import 'package:mobile_app/widgets/channel_display.dart';
import 'package:mobile_app/widgets/peer_display.dart';

class ChannelDetail extends StatefulWidget {
  final String chanId;

  const ChannelDetail({Key key, this.chanId}) : super(key: key);

  _ChannelDetailState createState() => _ChannelDetailState();
}

class _ChannelDetailState extends State<ChannelDetail> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
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
            if (channelState.channels.isEmpty) {
              return Text("Loading");
            }

            LnChannel chan = channelState.getChannelById(widget.chanId);
            LnPeer peer = peerState.getPeerById(chan.remotePubkey);

            return WillPopScope(
              onWillPop: () {
                Navigator.of(context).pop();
              },
              child: Scaffold(
                appBar: AppBar(
                  title: Text("Channel Details"),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      ChannelDisplay(chan),
                      PeerDisplay(peer, null),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          CloseChannelBloc _closeChannelBloc =
                              BlocProvider.of<CloseChannelBloc>(context);

                          return BlocProvider<CloseChannelBloc>(
                            bloc: _closeChannelBloc,
                            child: CloseChannelPage(
                              channel: chan,
                            ),
                          );
                        }),
                      );
                    },
                    heroTag: "close",
                    backgroundColor: theme.accentColor,
                    mini: false,
                    child: Icon(Icons.link_off)),
              ),
            );
          },
        );
      },
    );
  }
}
