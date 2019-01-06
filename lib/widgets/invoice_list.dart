/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/list_invoices/list_invoices_bloc.dart';
import 'package:mobile_app/blocs/list_invoices/list_invoices_bloc_state.dart';
import 'package:mobile_app/widgets/bottom_loader.dart';
import 'package:mobile_app/widgets/list_items/invoice_list_item.dart';

class InvoiceList extends StatefulWidget {
  _InvoiceListState createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  ListInvoicesBloc _bloc;
  bool _isLoading = false;
  bool _hasReachedEnd = false;

  _InvoiceListState() {
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
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
