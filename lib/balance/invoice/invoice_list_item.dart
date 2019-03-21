/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/common/types/lninvoice.dart';

class InvoiceListItem extends StatelessWidget {
  final LnInvoice _invoice;

  const InvoiceListItem(this._invoice);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color color;
    if (_invoice.settled) {
      color = Colors.greenAccent;
    } else {
      int now = DateTime.now().millisecondsSinceEpoch * 1000;
      int expiryTime = _invoice.creationDate
              .add(Duration(seconds: _invoice.expiry))
              .millisecondsSinceEpoch *
          1000;
      if (now > expiryTime) {
        color = Colors.redAccent;
      } else {
        color = Colors.yellowAccent;
      }
    }

    String dt = formatDate(
      _invoice.creationDate,
      [M, "-", dd, " ", hh, ":", nn],
    );

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 16.0),
              child: Container(
                height: 65.0,
                width: 8.0,
                color: color,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _invoice.memo.isNotEmpty ? _invoice.memo : "No memo",
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  "${_invoice.value.toString()} sat",
                  style: theme.textTheme.display1,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.clip,
                  maxLines: 1,
                ),
              ),
            )
          ],
        ),
        Divider()
      ],
    );
  }
}
