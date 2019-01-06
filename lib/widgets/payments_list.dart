/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/list_payments/list_payments_bloc.dart';
import 'package:mobile_app/blocs/list_payments/list_payments_bloc_state.dart';
import 'package:mobile_app/widgets/bottom_loader.dart';
import 'package:mobile_app/widgets/list_items/payment_list_item.dart';

class PaymentsList extends StatefulWidget {
  _PaymentsListState createState() => _PaymentsListState();
}

class _PaymentsListState extends State<PaymentsList> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  ListPaymentsBloc _bloc;
  bool _isLoading = false;
  bool _hasReachedEnd = false;

  _PaymentsListState() {
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of<ListPaymentsBloc>(context);
    return BlocBuilder(
        bloc: _bloc,
        builder: (BuildContext context, ListPaymentsState state) {
          Widget body;
          if (state.error.isNotEmpty) {
            body = Center(
              child: Text('failed to fetch invoices'),
            );
          }

          if (state.payments.isEmpty && state.isLoading) {
            body = Column(
              children: <Widget>[
                LinearProgressIndicator(),
              ],
            );
          } else if (state.payments.isEmpty && !state.isLoading) {
            body = Center(
              child: Text('no payments'),
            );
          }

          if (body == null) {
            body = ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return index >= state.payments.length
                    ? BottomLoader()
                    : PaymentListItem(state.payments[index]);
              },
              itemCount: state.hasReachedEnd
                  ? state.payments.length
                  : state.payments.length + 1,
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
      _bloc.loadPayments();
    }
  }
}
