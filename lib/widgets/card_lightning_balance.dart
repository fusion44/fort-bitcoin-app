/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/blocs/list_invoices/list_invoices_bloc.dart';
import 'package:mobile_app/blocs/list_payments/list_payments_bloc.dart';
import 'package:mobile_app/gql/types/lnchannelbalance.dart';
import 'package:mobile_app/gql/types/lninvoice.dart';
import 'package:mobile_app/gql/types/lnpayment.dart';
import 'package:mobile_app/gql/utils.dart';
import 'package:mobile_app/models.dart';
import 'package:mobile_app/pages/lightning_transfers.dart';
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
  // int = unix time of transfer
  // dynamic = LnPayment or LnInvoice
  SplayTreeMap<int, dynamic> _transactionData = SplayTreeMap((int a, int b) {
    // Sort newest to oldest
    if (a > b) return -1;
    if (a == b) return 0;
    return 1;
  });
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
        Map listInvoices = responses.data["lnListInvoices"];
        Map listPayments = responses.data["lnListPayments"];
        Map channelBalance = responses.data["lnGetChannelBalance"];

        _transactionData.clear();
        if (listInvoices["__typename"] == "ListInvoicesSuccess") {
          for (var invoice in listInvoices["invoices"]) {
            if (invoice["settled"]) {
              _transactionData[invoice["creationDate"]] = LnInvoice(invoice);
            }
          }
        } else if (listInvoices["__typename"] == "ServerError" ||
            listInvoices["__typename" == "ListInvoicesError"]) {
          var error = DataFetchError(
              -1, listInvoices["errorMessage"], _fetchPaymentsErrorkey);
          _errorMessages[_fetchPaymentsErrorkey] = error;
          print("Error fetching payments: ${error.message}");
        }

        // preprocess payments data
        if (listPayments["__typename"] == "ListPaymentsSuccess") {
          List payments = listPayments["payments"];
          for (var tx in payments) {
            LnPayment payment = LnPayment(tx);
            _transactionData[tx["creationDate"]] = payment;
          }
        } else if (channelBalance["__typename"] == "WalletInstanceNotFound") {
          onWalletNotFound();
          return;
        } else {
          var error = DataFetchError(
              -1, listPayments["errorMessage"], _fetchPaymentsErrorkey);
          _errorMessages[_fetchPaymentsErrorkey] = error;
          print("Error fetching payments: ${error.message}");
        }

        if (channelBalance["__typename"] == "GetChannelBalanceSuccess") {
          _balanceData = LnChannelBalance(channelBalance["lnChannelBalance"]);
        } else if (channelBalance["__typename"] == "WalletInstanceNotFound") {
          onWalletNotFound();
          return;
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
          _transactionData = _transactionData;
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

  void onWalletNotFound() {
    Navigator.pushNamed(this.context, "/setup_wallet");
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
    if (_transactionData.length == 0) {
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
                  child: Text("-${payment.value} $unit")),
              Text("TODO: paym. comment")
            ],
          ));
        }
      }
    }
    return CardBase(
        _header,
        InkWell(
          child: Column(children: children),
          onTap: () {
            GraphQLClient qlClient = GraphQLProvider.of(context).value;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return BlocProvider<ListPaymentsBloc>(
                  bloc: ListPaymentsBloc(qlClient),
                  child: BlocProvider<ListInvoicesBloc>(
                    bloc: ListInvoicesBloc(qlClient),
                    child: LightningTransfersPage(),
                  ),
                );
              }),
            );
          },
        ),
        _loading);
  }
}
