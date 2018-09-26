/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/gql/types/lnchannelbalance.dart';
import 'package:mobile_app/gql/types/lnpayment.dart';
import 'package:mobile_app/gql/utils.dart';
import 'package:mobile_app/models.dart';
import 'package:mobile_app/widgets/balance_display_lightning.dart';
import 'package:mobile_app/widgets/card_base.dart';
import 'package:mobile_app/widgets/card_error.dart';
import '../gql/queries/combined.dart' as combi_queries;
import 'package:date_format/date_format.dart';

class CardLightningBalance extends StatefulWidget {
  final bool _testnet;

  CardLightningBalance([this._testnet = false]);

  CardLightningBalanceState createState() => CardLightningBalanceState();
}

class CardLightningBalanceState extends State<CardLightningBalance> {
  final String _localErrorKey = "local_error";
  final String _fetchPaymentsErrorkey = "fetch_payments_error";
  final String _fetchBalanceErrorkey = "fetch_chan_balance_error";
  bool _loading = true;
  LnChannelBalance _balanceData;
  List<LnPayment> _txData = [];
  GraphQLClient _client;
  Map<String, DataFetchError> _errorMessages = Map();
  String _header;

  @override
  void initState() {
    if (widget._testnet) {
      _header = "Lightning Testnet";
    } else {
      _header = "Lightning Mainnet";
    }

    _balanceData = LnChannelBalance({});

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
      QueryResult responses = await _client
          .query(QueryOptions(document: combi_queries.getLightningFinanceInfo));

      if (this.mounted) {
        Map listPayments = responses.data["lnListPayments"];
        Map channelBalance = responses.data["lnGetChannelBalance"];

        // preprocess payments data
        _txData.clear();
        if (listPayments["__typename"] == "ListPaymentsSuccess") {
          List payments = listPayments["lnTransactionDetails"]["payments"];
          for (var tx in payments) {
            _txData.add(LnPayment(tx));
          }
        } else {
          var error = DataFetchError(
              -1, listPayments["errorMessage"], _fetchPaymentsErrorkey);
          _errorMessages[_fetchPaymentsErrorkey] = error;
          print("Error fetching payments: ${error.message}");
        }
        // Sort all payments by creation date so the newest
        // payment is shown first
        _txData.sort((first, second) =>
            second.creationDate.compareTo(first.creationDate));

        if (channelBalance["__typename"] == "GetChannelBalanceSuccess") {
          _balanceData = LnChannelBalance(channelBalance["lnChannelBalance"]);
        } else {
          var error = DataFetchError(
              -1, channelBalance["errorMessage"], _fetchBalanceErrorkey);
          _errorMessages[_fetchBalanceErrorkey] = error;
          print("Error fetching channel balance: ${error.message}");
        }

        _errorMessages.addAll(processGraphqlErrors(responses));
        setState(() {
          _errorMessages = _errorMessages;
          _loading = false;
          _balanceData = _balanceData;
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
    if (_errorMessages.isNotEmpty) {
      return ErrorDisplayCard(_header, _errorMessages.values);
    }

    String unit = widget._testnet ? "tsats" : "sats";

    List<Widget> children = [];
    children.add(Padding(
        padding: EdgeInsets.only(bottom: 10.0),
        child: BalanceDisplayLightning(_balanceData, widget._testnet)));
    if (_txData.length == 0) {
      children.add(Text("No payments yet"));
    } else {
      int maxRange = _txData.length > 5 ? 5 : _txData.length;
      for (LnPayment p in _txData.getRange(0, maxRange)) {
        String dt = formatDate(p.creationDate, [M, "-", dd, " ", hh, ":", nn]);
        children.add(Row(
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
                child: Text("${p.value} $unit")),
            Text("TODO: paym. comment")
          ],
        ));
      }
    }
    return CardBase(_header, Column(children: children), _loading);
  }
}
