/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:async';

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/gql/types/lntransaction.dart';
import 'package:mobile_app/gql/types/lnwalletbalance.dart';
import 'package:mobile_app/gql/utils.dart';
import 'package:mobile_app/models.dart';
import 'package:mobile_app/widgets/balance_display_onchain.dart';
import 'package:mobile_app/widgets/card_base.dart';
import 'package:mobile_app/widgets/card_error.dart';
import '../gql/queries/combined.dart' as combi_queries;

class CardOnchainBalance extends StatefulWidget {
  final bool _testnet;

  CardOnchainBalance([this._testnet = false]);

  CardOnchainBalanceState createState() => CardOnchainBalanceState();
}

class CardOnchainBalanceState extends State<CardOnchainBalance> {
  final String _localErrorKey = "local_error";
  bool _loading = true;
  LnWalletBalance _balanceData;
  List<LnTransaction> _txData = [];
  GraphQLClient _client;
  Map<String, DataFetchError> _errorMessages = Map();
  String _header;

  @override
  void initState() {
    if (widget._testnet) {
      _header = "Onchain Testnet";
    } else {
      _header = "Onchain Mainnet";
    }

    _balanceData = LnWalletBalance({});

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_client == null) {
      _client = GraphQLProvider.of(context).value;

      // initial fetch
      _fetchData();
    }
    super.didChangeDependencies();
  }

  Future _fetchData() async {
    setState(() {
      _loading = true;
    });

    //reset old error messages
    _errorMessages.clear();
    try {
      var v = {"testnet": widget._testnet};
      QueryResult responses = await _client.query(QueryOptions(
          document: combi_queries.getOnchainFinanceInfo, variables: v));

      if (this.mounted) {
        // preprocess transactions data
        _txData.clear();
        List transactions = responses.data["lnGetTransactions"]["transactions"];
        for (var tx in transactions) {
          _txData.add(LnTransaction(tx));
        }
        // Sort all transactions by creation date so the newest
        // transactions is shown first
        _txData.sort(
            (first, second) => second.timeStamp.compareTo(first.timeStamp));

        setState(() {
          _errorMessages = processGraphqlErrors(responses);
          _loading = false;
          _balanceData = LnWalletBalance(responses.data["lnGetWalletBalance"]);
          _txData = _txData;
        });
      }
    } on TypeError catch (error) {
      // Process client errors like 404's
      DataFetchError err = DataFetchError(-1, error.toString(), _localErrorKey);
      _errorMessages[_localErrorKey] = err;
      print(error);
      print(error.stackTrace);
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && _errorMessages.containsKey(_localErrorKey)) {
      return ErrorDisplayCard(_header, _errorMessages[_localErrorKey]);
    }

    String unit = widget._testnet ? "tsats" : "sats";

    List<Widget> children = [];
    children.add(Padding(
        padding: EdgeInsets.only(bottom: 10.0),
        child: BalanceDisplayOnchain(_balanceData.totalBalance,
            _balanceData.unconfirmedBalance, widget._testnet)));
    if (_txData.length == 0) {
      children.add(Text("No transactions yet"));
    } else {
      for (LnTransaction p in _txData.getRange(0, 5)) {
        String dt = formatDate(p.timeStamp, [M, "-", dd, " ", hh, ":", nn]);
        IconData ic = p.amount > 0 ? Icons.arrow_forward : Icons.arrow_back;
        Color iconColor = p.amount > 0 ? Colors.green : Colors.red;

        children.add(Row(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: Icon(
                  ic,
                  color: iconColor,
                )),
            Padding(padding: EdgeInsets.only(right: 5.0), child: Text(dt)),
            Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: Text("${p.amount} $unit")),
            Text("TODO: paym. comment")
          ],
        ));
      }
    }
    return CardBase(_header, Column(children: children), _loading);
  }
}
