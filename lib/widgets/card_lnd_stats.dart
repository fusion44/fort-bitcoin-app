/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/card_base.dart';
import 'package:mobile_app/widgets/simple_metric.dart';

class CardLndStats extends StatelessWidget {
  final bool _loading;
  final bool _testnet;
  final String _alias;
  final int _blockHeight;
  final String _identityPubkey;
  final int _numActiveChannels;
  final int _numInactiveChannels;
  final int _numPendingChannels;
  final int _numPeers;
  final bool _syncedToChain;
  final String _version;

  CardLndStats(
      [this._loading,
      this._testnet = true,
      this._alias = "",
      this._blockHeight = -1,
      this._identityPubkey = "",
      this._numActiveChannels = -1,
      this._numInactiveChannels = -1,
      this._numPendingChannels = -1,
      this._numPeers = -1,
      this._syncedToChain = false,
      this._version = ""]);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    String header = "Lightning Mainnet";
    if (_testnet) {
      header = "Lightning Testnet";
    }
    return CardBase(
        header,
        Wrap(
            spacing: 15.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.center,
            children: <Widget>[
              SimpleMetricWidget("Alias", _alias),
              SimpleMetricWidget("Blockheight", _blockHeight.toString()),
              SimpleMetricWidget("Version", _version.toString()),
              SimpleMetricWidget(
                  "Active Channels", _numActiveChannels.toString()),
              SimpleMetricWidget(
                  "Inactive Channels", _numInactiveChannels.toString()),
              _numPendingChannels > 0
                  ? SimpleMetricWidget(
                      "Pending Channels", _numPendingChannels.toString())
                  : Container(),
              SimpleMetricWidget("Peers", _numPeers.toString()),
              SimpleMetricWidget("Synched", _syncedToChain.toString()),
            ]),
        _loading);
  }
}
