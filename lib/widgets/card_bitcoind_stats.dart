/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/card_base.dart';
import 'package:mobile_app/widgets/simple_metric.dart';

class CardBitcoindStats extends StatelessWidget {
  final bool _loading;
  final bool _testnet;
  final int _blocks;
  final String _subversion;
  final int _connections;
  final String _warnings;

  CardBitcoindStats([
    this._loading,
    this._testnet = false,
    this._blocks = 0,
    this._subversion = "",
    this._connections = 0,
    this._warnings = "",
  ]);

  @override
  Widget build(BuildContext context) {
    String header = "Bitcoind Mainnet";
    if (_testnet) {
      header = "Bitcoind Testnet";
    }

    return CardBase(
        header,
        Wrap(
            spacing: 15.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.center,
            children: <Widget>[
              SimpleMetricWidget("Version", _subversion),
              SimpleMetricWidget("Blockheight", _blocks.toString()),
              SimpleMetricWidget("Connections", _connections.toString()),
              _warnings != ""
                  ? SimpleMetricWidget("Warnings", _warnings)
                  : Container()
            ]),
        _loading);
  }
}
