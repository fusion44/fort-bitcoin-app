/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/common/types/lnpeer.dart';
import 'package:mobile_app/common/widgets/simple_data_row_widget.dart';
import 'package:mobile_app/connectivity/channels/open/open_channel.dart';
import 'package:mobile_app/connectivity/channels/open/open_channel_page.dart';
import 'package:mobile_app/connectivity/peer/peer_bloc.dart';

class _Choice {
  const _Choice(this.peer, this.title);

  final LnPeer peer;
  final String title;
}

class PeerDisplayWidget extends StatefulWidget {
  final LnPeer _data;
  final Function _onDisconnect;
  PeerDisplayWidget(this._data, this._onDisconnect);

  _PeerDisplayWidgetState createState() => _PeerDisplayWidgetState();
}

class _PeerDisplayWidgetState extends State<PeerDisplayWidget> {
  OpenChannelBloc _openChannelBloc;
  PeerBloc _peerBloc;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    _openChannelBloc = BlocProvider.of<OpenChannelBloc>(context);
    _peerBloc = BlocProvider.of<PeerBloc>(context);

    return Card(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 45.0,
                    ),
                    Expanded(
                      child: Text(
                        "Peer",
                        style: theme.textTheme.headline,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    PopupMenuButton<_Choice>(
                      itemBuilder: (BuildContext context) {
                        List<_Choice> _choices = <_Choice>[
                          _Choice(widget._data, 'Disconnect'),
                          _Choice(widget._data, 'Open Channel'),
                        ];
                        return _choices.map(
                          (_Choice choice) {
                            return PopupMenuItem<_Choice>(
                              value: choice,
                              child: Text(choice.title),
                            );
                          },
                        ).toList();
                      },
                      onSelected: _select,
                    ),
                  ],
                ),
                SimpleDataRowWidget(
                    left: "Address", right: widget._data.address),
                SimpleDataRowWidget(
                    left: "Bytes sent", right: widget._data.bytesSent),
                SimpleDataRowWidget(
                    left: "Bytes recv", right: widget._data.bytesRecv),
                SimpleDataRowWidget(
                    left: "Sats sent", right: widget._data.satSent),
                SimpleDataRowWidget(
                    left: "Sats recv", right: widget._data.satRecv),
                SimpleDataRowWidget(
                    left: "Inbound", right: widget._data.inbound),
                SimpleDataRowWidget(left: "Ping", right: widget._data.pingTime),
                widget._data.hasChannel
                    ? SimpleDataRowWidget(
                        left: "Open Channel",
                        right: "Yes",
                      )
                    : SimpleDataRowWidget(
                        left: "Open Channel",
                        right: "No",
                      )
              ],
            ),
          ),
          Container(
            width: 8.0,
          )
        ],
      ),
    );
  }

  void _select(_Choice value) {
    switch (value.title) {
      case "Disconnect":
        widget._onDisconnect(value.peer.pubKey);
        break;
      case "Open Channel":
        if (value.peer.hasChannel) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text("Peer already has an open channel!")));
          break;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProviderTree(
                  blocProviders: [
                    BlocProvider<PeerBloc>(bloc: _peerBloc),
                    BlocProvider<OpenChannelBloc>(bloc: _openChannelBloc),
                  ],
                  child: OpenChannelPage(peer: value.peer),
                ),
          ),
        );
        break;
      default:
    }
  }
}
