/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/gql/types/lnchannelbalance.dart';
import 'package:mobile_app/widgets/simple_metric.dart';

class BalanceDisplayLightning extends StatelessWidget {
  final LnChannelBalance _balance;
  final bool _testnet;

  BalanceDisplayLightning(this._balance, [this._testnet = false]);

  @override
  Widget build(BuildContext context) {
    String unit = _testnet ? "tStatoshis" : "Satoshis";
    String bal = _balance?.balance.toString() ?? "0";
    String pbal = _balance?.pendingOpenBalance.toString() ?? "0";

    return Wrap(
      spacing: 15.0,
      runSpacing: 4.0,
      runAlignment: WrapAlignment.start,
      children: <Widget>[
        SimpleMetricWidget("Total", "$bal", unit),
        SimpleMetricWidget("Pending", "$pbal", unit),
      ],
    );
  }
}
