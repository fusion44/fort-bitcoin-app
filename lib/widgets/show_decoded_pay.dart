/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/gql/types/lnpayreq.dart';
import 'package:mobile_app/widgets/simple_metric.dart';

class ShowDecodedPay extends StatelessWidget {
  final LnPayReq _payReq;

  ShowDecodedPay(this._payReq);

  @override
  Widget build(BuildContext context) {
    if (_payReq == null) {
      return Text("Pay request not valid.");
    }

    return Column(
      children: <Widget>[
        SimpleMetricWidget(
            "Date",
            DateTime
                .fromMillisecondsSinceEpoch(_payReq.timestamp * 1000)
                .toString()),
        SimpleMetricWidget("Destination", _payReq.destination),
        SimpleMetricWidget("Description", _payReq.description),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: SimpleMetricWidget(
                  "Satoshis", _payReq.numSatoshis.toString())),
          Padding(
              padding: EdgeInsets.only(left: 50.0, right: 10.0),
              child: SimpleMetricWidget("Expires", _payReq.expiry.toString())),
        ])
      ],
    );
  }
}
