/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/gql/types/lnpeer.dart';

import 'package:mobile_app/widgets/simple_data_row.dart';

class _Choice {
  const _Choice(this.peer, this.title);

  final LnPeer peer;
  final String title;
}

class PeerDisplay extends StatefulWidget {
  final LnPeer _data;
  final Function _onDisconnect;
  PeerDisplay(this._data, this._onDisconnect);

  _PeerDisplayState createState() => _PeerDisplayState();
}

class _PeerDisplayState extends State<PeerDisplay> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

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
                          _Choice(widget._data, 'Locate'),
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
                SimpleDataRow(left: "Address", right: widget._data.address),
                SimpleDataRow(
                    left: "Bytes sent", right: widget._data.bytesSent),
                SimpleDataRow(
                    left: "Bytes recv", right: widget._data.bytesRecv),
                SimpleDataRow(left: "Sats sent", right: widget._data.satSent),
                SimpleDataRow(left: "Sats recv", right: widget._data.satRecv),
                SimpleDataRow(left: "Inbound", right: widget._data.inbound),
                SimpleDataRow(left: "Ping", right: widget._data.pingTime),
                widget._data.hasChannel
                    ? SimpleDataRow(
                        left: "Open Channel",
                        right: "Yes",
                      )
                    : SimpleDataRow(
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
      case "Locate":
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text("Not yet implemented!")));
        break;
      default:
    }
  }
}
