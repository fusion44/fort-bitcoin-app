/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/list_invoices/list_invoices_bloc.dart';
import 'package:mobile_app/blocs/list_invoices/list_invoices_bloc_state.dart';
import 'package:mobile_app/gql/types/lninvoice.dart';

class LightningTransfersPage extends StatefulWidget {
  _LightningTransfersPageState createState() => _LightningTransfersPageState();
}

class _LightningTransfersPageState extends State<LightningTransfersPage> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  ListInvoicesBloc _bloc;

  _LightningTransfersPageState() {
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    _bloc = BlocProvider.of<ListInvoicesBloc>(context);

    return BlocBuilder(
      bloc: _bloc,
      builder: (BuildContext context, ListInvoicesState state) {
        Widget body;
        if (state.error.isNotEmpty) {
          body = Center(
            child: Text('failed to fetch invoices'),
          );
        }
        if (state.invoices.isEmpty) {
          body = Center(
            child: Text('no invoices'),
          );
        }

        if (body == null) {
          body = ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return index >= state.invoices.length
                  ? _bottomLoader()
                  : _invoiceWidget(index, state.invoices[index], theme);
            },
            itemCount: state.hasReachedEnd
                ? state.invoices.length
                : state.invoices.length + 1,
            controller: _scrollController,
          );
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Lightning Transfers'),
              bottom: TabBar(
                isScrollable: true,
                tabs: <Widget>[
                  Tab(
                    text: "Invoices",
                  ),
                  Tab(
                    text: "Payments",
                  )
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                body,
                ListView(children: [Text("1"), Text("2")])
              ],
            ),
          ),
        );
      },
    );
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _bloc.loadInvoices();
    }
  }

  Widget _invoiceWidget(int index, LnInvoice invoice, [ThemeData theme]) {
    Color color;
    if (invoice.settled) {
      color = Colors.greenAccent;
    } else {
      int now = DateTime.now().millisecondsSinceEpoch * 1000;
      int expiryTime = invoice.creationDate
              .add(Duration(seconds: invoice.expiry))
              .millisecondsSinceEpoch *
          1000;
      if (now > expiryTime) {
        color = Colors.redAccent;
      } else {
        color = Colors.yellowAccent;
      }
    }

    String dt =
        formatDate(invoice.creationDate, [M, "-", dd, " ", hh, ":", nn]);

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
                    invoice.memo.isNotEmpty ? invoice.memo : "No memo",
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
                  "${invoice.value.toString()} sat",
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

  Widget _bottomLoader() => Container(
        alignment: Alignment.center,
        child: Center(
          child: SizedBox(
            width: 33,
            height: 33,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
            ),
          ),
        ),
      );
}
