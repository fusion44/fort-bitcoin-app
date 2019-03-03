/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:mobile_app/gql/types/lnchannelbalance.dart';
import 'package:mobile_app/gql/types/lninvoice.dart';
import 'package:mobile_app/gql/types/lnpayment.dart';
import 'package:mobile_app/pages/lightning_transfers.dart';
import 'package:mobile_app/widgets/balance_display_lightning.dart';
import 'package:mobile_app/widgets/card_base.dart';
import 'package:date_format/date_format.dart';

class CardLightningBalance extends StatelessWidget {
  final SplayTreeMap<int, dynamic> _transactionData;
  final LnChannelBalance _balanceData;
  final bool _testnet;

  CardLightningBalance(
      [this._transactionData, this._balanceData, this._testnet = false]);

  @override
  Widget build(BuildContext context) {
    String header = _testnet ? "Lightning Testnet" : "Lightning Mainnet";
    String unit = _testnet ? "tsats" : "sats";

    List<Widget> children = [];
    children.add(Padding(
        padding: EdgeInsets.only(bottom: 10.0),
        child: BalanceDisplayLightning(_balanceData, _testnet)));
    if (_transactionData == null || _transactionData.length == 0) {
      children.add(Text("No payments yet"));
    } else {
      int maxRange =
          _transactionData.length > 10 ? 10 : _transactionData.length;
      var range = _transactionData.values.toList().getRange(0, maxRange);
      for (dynamic value in range) {
        if (value is LnInvoice) {
          LnInvoice invoice = value;
          String dt =
              formatDate(invoice.creationDate, [M, "-", dd, " ", hh, ":", nn]);

          children.add(Row(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.green,
                  )),
              Padding(padding: EdgeInsets.only(right: 5.0), child: Text(dt)),
              Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Text("${invoice.value} $unit")),
              Expanded(
                child: Text(
                  invoice.memo,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              )
            ],
          ));
        } else {
          LnPayment payment = value;
          String dt =
              formatDate(payment.creationDate, [M, "-", dd, " ", hh, ":", nn]);

          children.add(
            Row(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.red,
                    )),
                Padding(padding: EdgeInsets.only(right: 5.0), child: Text(dt)),
                Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: Text("-${payment.value} $unit")),
                Text("TODO: paym. comment")
              ],
            ),
          );
        }
      }
    }
    return CardBase(
        header,
        InkWell(
          child: Column(children: children),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return LightningTransfersPage();
                },
              ),
            );
          },
        ),
        false);
  }
}
