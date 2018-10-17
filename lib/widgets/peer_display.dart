/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/gql/types/lnpeer.dart';

import 'package:mobile_app/widgets/simple_data_row.dart';

class PeerDisplay extends StatelessWidget {
  final LnPeer _data;
  PeerDisplay(this._data);

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
                Text(
                  "Peer",
                  style: theme.textTheme.headline,
                ),
                SimpleDataRow(left: "Address", right: _data.address),
                SimpleDataRow(left: "Bytes sent", right: _data.bytesSent),
                SimpleDataRow(left: "Bytes recv", right: _data.bytesRecv),
                SimpleDataRow(left: "Sats sent", right: _data.satSent),
                SimpleDataRow(left: "Sats recv", right: _data.satRecv),
                SimpleDataRow(left: "Inbound", right: _data.inbound),
                SimpleDataRow(left: "Ping", right: _data.pingTime),
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
}
