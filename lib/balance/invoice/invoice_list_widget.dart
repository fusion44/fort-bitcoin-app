/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/balance/invoice/invoice.dart';
import 'package:mobile_app/balance/invoice/invoice_list_item.dart';
import 'package:mobile_app/common/widgets/bottom_loader.dart';

class InvoiceListWidget extends StatefulWidget {
  _InvoiceListWidgetState createState() => _InvoiceListWidgetState();
}

class _InvoiceListWidgetState extends State<InvoiceListWidget> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  ListInvoiceBloc _bloc;
  bool _isLoading = false;
  bool _hasReachedEnd = false;

  _InvoiceListWidgetState() {
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of<ListInvoiceBloc>(context);
    return BlocBuilder(
        bloc: _bloc,
        builder: (BuildContext context, ListInvoicesState state) {
          Widget body;
          if (state.error.isNotEmpty) {
            body = Center(
              child: Text('failed to fetch invoices'),
            );
          }

          if (state.invoices.isEmpty && state.isLoading) {
            body = Column(
              children: <Widget>[
                LinearProgressIndicator(),
              ],
            );
          } else if (state.invoices.isEmpty && !state.isLoading) {
            body = Center(
              child: Text('no invoices'),
            );
          }

          if (body == null) {
            body = ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return index >= state.invoices.length
                    ? BottomLoader()
                    : InvoiceListItem(state.invoices[index]);
              },
              itemCount: state.hasReachedEnd
                  ? state.invoices.length
                  : state.invoices.length + 1,
              controller: _scrollController,
            );
          }

          _isLoading = state.isLoading;
          _hasReachedEnd = state.hasReachedEnd;

          return Container(child: body);
        });
  }

  void _onScroll() {
    if (_hasReachedEnd || _isLoading) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _bloc.loadInvoices();
    }
  }
}
