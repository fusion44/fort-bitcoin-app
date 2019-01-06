/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/gql/types/lnpayment.dart';

class PaymentListItem extends StatelessWidget {
  final LnPayment _payment;
  PaymentListItem(this._payment);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    String dt =
        formatDate(this._payment.creationDate, [M, "-", dd, " ", hh, ":", nn]);

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "No memo",
                      style: theme.textTheme.body2,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(dt, style: theme.textTheme.body1),
                    )
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "${this._payment.value.toString()} sat",
                    style: theme.textTheme.display1,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                  ),
                  Text("fee: ${this._payment.fee.toString()} sat",
                      textAlign: TextAlign.right, style: theme.textTheme.body1)
                ],
              )
            ],
          ),
          Divider()
        ],
      ),
    );
  }
}
