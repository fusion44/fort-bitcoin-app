/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/common/widgets/simple_metric_widget.dart';

class OnchainBalanceWidget extends StatelessWidget {
  final int _total;
  final int _unconfirmed;
  final bool _testnet;

  OnchainBalanceWidget(this._total, this._unconfirmed, [this._testnet = false]);

  @override
  Widget build(BuildContext context) {
    String unit = _testnet ? "tStatoshis" : "Satoshis";
    String total = (_total ?? 0).toString();
    String unconfirmed = (_unconfirmed ?? 0).toString();

    return Wrap(
      spacing: 15.0,
      runSpacing: 4.0,
      runAlignment: WrapAlignment.start,
      children: <Widget>[
        SimpleMetricWidget("Total", "$total", unit),
        SimpleMetricWidget("Unconfirmed", "$unconfirmed", unit),
      ],
    );
  }
}
