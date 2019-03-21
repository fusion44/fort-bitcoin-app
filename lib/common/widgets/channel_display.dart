/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/common/types/lnchannel.dart';
import 'package:mobile_app/common/types/lnpeer.dart';
import 'package:mobile_app/common/widgets/simple_data_row_widget.dart';
import 'package:mobile_app/connectivity/channels/channel_detail.dart';
import 'package:mobile_app/connectivity/channels/single_channel_balance_widget.dart';

class ChannelDisplayWidget extends StatelessWidget {
  final LnChannel _data;
  final LnPeer _peer;
  ChannelDisplayWidget(this._data, this._peer);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    var blockHeight = int.parse(_data.chanId) >> 40;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                ChannelDetail(chanId: this._data.chanId),
          ),
        );
      },
      child: Card(
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                width: 5.0,
                height: 150.0,
                color: this._peer == null ? Colors.red : Colors.green,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "ID: ${_data.chanId}",
                    style: theme.textTheme.headline,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(child: Text("Local Balance")),
                      Expanded(
                        child: Text(
                          "Remote Balance",
                          textAlign: TextAlign.right,
                        ),
                      )
                    ],
                  ),
                  SingleChannelBalanceWidget(
                      _data.localBalance, _data.remoteBalance),
                  SimpleDataRowWidget(left: "Capacity", right: _data.capacity),
                  SimpleDataRowWidget(left: "Established", right: blockHeight),
                  SimpleDataRowWidget(
                      left: "Sent", right: _data.totalSatoshisSent),
                  SimpleDataRowWidget(
                    left: "Received",
                    right: _data.totalSatoshisReceived,
                  ),
                  SimpleDataRowWidget(
                    left: "Unsettled",
                    right: _data.unsettledBalance,
                  ),
                  SimpleDataRowWidget(left: "Updates", right: _data.numUpdates)
                ],
              ),
            ),
            Container(width: 8.0)
          ],
        ),
      ),
    );
  }
}
