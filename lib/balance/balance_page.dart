/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/balance/channel_balance/channel_balance.dart';
import 'package:mobile_app/balance/channel_balance/channel_balance_card.dart';
import 'package:mobile_app/balance/invoice/invoice.dart';
import 'package:mobile_app/balance/onchain_data/onchain_balance_card.dart';
import 'package:mobile_app/balance/onchain_data/onchain_data.dart';
import 'package:mobile_app/balance/payment/payment.dart';
import 'package:mobile_app/common/types/lninvoice.dart';
import 'package:mobile_app/common/types/lnpayment.dart';
import 'package:mobile_app/common/widgets/card_error.dart';
import 'package:mobile_app/models.dart';

class BalancesPage extends StatefulWidget {
  static IconData icon = Icons.all_inclusive;
  static String appBarText = "Balances";
  final bool _testnet;

  BalancesPage([this._testnet = false]);

  @override
  _BalancesPageState createState() => _BalancesPageState();
}

class _BalancesPageState extends State<BalancesPage> {
  Completer<void> _refreshCompleter;

  @override
  Widget build(BuildContext context) {
    OnchainDataBloc onchainBloc = BlocProvider.of<OnchainDataBloc>(context);
    ChannelBalanceBloc channelBloc =
        BlocProvider.of<ChannelBalanceBloc>(context);
    ListInvoiceBloc invoicesBloc = BlocProvider.of<ListInvoiceBloc>(context);
    ListPaymentBloc paymentsBloc = BlocProvider.of<ListPaymentBloc>(context);

    return BlocBuilder(
        bloc: onchainBloc,
        builder: (
          BuildContext onchainCtx,
          OnchainDataState onchainState,
        ) {
          return BlocBuilder(
              bloc: channelBloc,
              builder: (
                BuildContext chanCtx,
                ChannelBalanceState channelState,
              ) {
                return BlocBuilder(
                    bloc: invoicesBloc,
                    builder: (
                      BuildContext invoiceCtx,
                      ListInvoicesState invoiceState,
                    ) {
                      return BlocBuilder(
                        bloc: paymentsBloc,
                        builder: (
                          BuildContext paymentsCtx,
                          ListPaymentState paymentsState,
                        ) {
                          return _buildUi(
                            onchainBloc,
                            onchainState,
                            channelBloc,
                            channelState,
                            invoicesBloc,
                            invoiceState,
                            paymentsBloc,
                            paymentsState,
                          );
                        },
                      );
                    });
              });
        });
  }

  Widget _buildUi(
      OnchainDataBloc onchainBloc,
      OnchainDataState onchainState,
      ChannelBalanceBloc channelBloc,
      ChannelBalanceState channelState,
      ListInvoiceBloc invoicesBloc,
      ListInvoicesState invoiceState,
      ListPaymentBloc paymentsBloc,
      ListPaymentState paymentsState) {
    List<Widget> children;
    children = [
      _buildOnchainWidget(onchainState),
      _buildChannelWidget(channelState, invoiceState, paymentsState)
    ];

    if (onchainState.type == OnchainDataEventType.finishLoading ||
        onchainState.type == OnchainDataEventType.failLoading &&
            channelState.type == ChannelBalanceEventType.finishLoading ||
        channelState.type == ChannelBalanceEventType.failLoading &&
            invoiceState.type == ListInvoiceEventType.finishLoading ||
        invoiceState.type == ListInvoiceEventType.failLoading &&
            paymentsState.type == ListPaymentEventType.finishLoading ||
        paymentsState.type == ListPaymentEventType.failLoading) {
      if (_refreshCompleter != null) {
        // reset pull to refresh
        _refreshCompleter.complete();
        _refreshCompleter = null;
      }
    } else {
      // something hasen't finished loading yet and refreshCompleter is null
      // this means, we're currently loading the initial dataset
      children.insert(0,
          _refreshCompleter == null ? LinearProgressIndicator() : Container());
    }

    return RefreshIndicator(
      onRefresh: () async {
        _refreshCompleter = Completer();
        onchainBloc.dispatch(LoadOnchainData());
        channelBloc.dispatch(LoadChannelBalanceEvent());
        invoicesBloc.dispatch(LoadInvoices());
        paymentsBloc.dispatch(LoadPayments());
        return _refreshCompleter.future;
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: children,
      ),
    );
  }

  Widget _buildOnchainWidget(OnchainDataState onchainState) {
    if (onchainState.type == OnchainDataEventType.failLoading) {
      return ErrorDisplayCard(
        "Onchain Error",
        [DataFetchError(-1, onchainState.error, "")],
      );
    } else {
      return CardOnchainBalance(
        onchainState.balance,
        onchainState.transactions.toList(),
      );
    }
  }

  Widget _buildChannelWidget(
    ChannelBalanceState channelState,
    ListInvoicesState invoiceState,
    ListPaymentState paymentsState,
  ) {
    if (channelState.type == ChannelBalanceEventType.failLoading ||
        invoiceState.type == ListInvoiceEventType.failLoading ||
        paymentsState.type == ListPaymentEventType.failLoading) {
      // handle any errors
      List<DataFetchError> errors = [];
      if (channelState.type == ChannelBalanceEventType.failLoading) {
        errors.add(
            DataFetchError(-1, "ChannelBalance: ${channelState.error}", ""));
      }
      if (invoiceState.type == ListInvoiceEventType.failLoading) {
        errors
            .add(DataFetchError(-1, "ListInvoices: ${invoiceState.error}", ""));
      }
      if (paymentsState.type == ListPaymentEventType.failLoading) {
        errors.add(
            DataFetchError(-1, "ListPayments: ${paymentsState.error}", ""));
      }
      return ErrorDisplayCard("Lightning Error", errors);
    } else {
      SplayTreeMap<int, dynamic> transactionData = SplayTreeMap((int a, int b) {
        // Sort newest to oldest
        if (a > b) return -1;
        if (a == b) return 0;
        return 1;
      });

      for (LnInvoice invoice in invoiceState.invoices) {
        transactionData[invoice.creationDate.millisecondsSinceEpoch] = invoice;
      }

      for (LnPayment payment in paymentsState.payments) {
        transactionData[payment.creationDate.millisecondsSinceEpoch] = payment;
      }

      return ChannelBalanceCard(
        transactionData,
        channelState.balance,
        widget._testnet,
      );
    }
  }
}
