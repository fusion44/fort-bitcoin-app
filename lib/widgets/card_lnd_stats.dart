/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/simple_metric.dart';

class CardLndStats extends StatelessWidget {
  final bool _loading;
  final bool _testnet;
  final String _alias;
  final int _blockHeight;
  final String _identityPubkey;
  final int _numActiveChannels;
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
      this._numPeers = -1,
      this._syncedToChain = false,
      this._version = ""]);

  @override
  Widget build(BuildContext context) {
    String header = "Lightning Mainnet";
    if (_testnet) {
      header = "Lightning Testnet";
    }
    return Card(
        elevation: 2.0,
        margin: EdgeInsets.all(10.0),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(bottom: 5.0),
                      child: Text(
                        header,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 25.0, fontWeight: FontWeight.bold),
                      ))
                ],
              ),
              _loading ? LinearProgressIndicator() : Container(),
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
                    SimpleMetricWidget("Peers", _numPeers.toString()),
                    SimpleMetricWidget("Synched", _syncedToChain.toString()),
                  ]),
            ],
          ),
        ));
  }
}
