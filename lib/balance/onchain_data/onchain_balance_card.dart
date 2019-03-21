/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/balance/onchain_data/onchain_balance_widget.dart';
import 'package:mobile_app/common/types/lntransaction.dart';
import 'package:mobile_app/common/types/lnwalletbalance.dart';
import 'package:mobile_app/common/widgets/card_base.dart';

class CardOnchainBalance extends StatelessWidget {
  final bool _testnet;
  final LnWalletBalance _balanceData;
  final List<LnTransaction> _txData;

  CardOnchainBalance(
    this._balanceData,
    this._txData, [
    Key key,
    this._testnet = false,
  ]) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String header = _testnet ? "Onchain Testnet" : "Onchain Mainnet";
    String unit = _testnet ? "tsats" : "sats";

    List<Widget> children = [];
    children.add(Padding(
        padding: EdgeInsets.only(bottom: 10.0),
        child: OnchainBalanceWidget(_balanceData.totalBalance,
            _balanceData.unconfirmedBalance, _testnet)));
    if (_txData.length == 0) {
      children.add(Text("No transactions yet"));
    } else {
      int max = _txData.length > 10 ? 10 : _txData.length;
      for (LnTransaction p in _txData.getRange(0, max)) {
        String dt = formatDate(p.timeStamp, [M, "-", dd, " ", hh, ":", nn]);
        IconData ic = p.amount > 0 ? Icons.arrow_forward : Icons.arrow_back;
        Color iconColor = p.amount > 0 ? Colors.green : Colors.red;

        children.add(
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: Icon(
                  ic,
                  color: iconColor,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: Text(dt),
              ),
              Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: Text("${p.amount} $unit"),
              ),
              Text("TODO: paym. comment")
            ],
          ),
        );
      }
    }
    return CardBase(
      header,
      Column(children: children),
    );
  }
}
