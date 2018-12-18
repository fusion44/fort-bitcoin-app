/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:meta/meta.dart';
import 'package:mobile_app/blocs/list_invoices/list_invoices_bloc_events.dart';
import 'package:mobile_app/gql/types/lninvoice.dart';
import 'package:built_collection/built_collection.dart';

class ListInvoicesState {
  final ListInvoiceEventType type;
  final bool isLoading;
  final bool hasReachedEnd;
  final String error;
  final BuiltList<LnInvoice> invoices;

  const ListInvoicesState({
    @required this.type,
    @required this.isLoading,
    @required this.hasReachedEnd,
    @required this.error,
    @required this.invoices,
  });

  factory ListInvoicesState.initial() {
    return ListInvoicesState(
      type: ListInvoiceEventType.initial,
      isLoading: true,
      hasReachedEnd: false,
      error: '',
      invoices: new BuiltList<LnInvoice>(),
    );
  }

  factory ListInvoicesState.loading(
      ListInvoiceEventType type, ListInvoicesState oldState) {
    return ListInvoicesState(
      type: type,
      isLoading: true,
      hasReachedEnd: oldState.hasReachedEnd,
      error: oldState.error,
      invoices: oldState.invoices,
    );
  }

  factory ListInvoicesState.failure(
      ListInvoiceEventType type, ListInvoicesState oldState, String error) {
    return ListInvoicesState(
      type: type,
      isLoading: oldState.isLoading,
      hasReachedEnd: oldState.hasReachedEnd,
      error: error,
      invoices: oldState.invoices,
    );
  }

  factory ListInvoicesState.success(
      ListInvoiceEventType type,
      List<LnInvoice> invoices,
      bool hasReachedEnd,
      ListInvoicesState oldState) {
    return ListInvoicesState(
      type: type,
      isLoading: false,
      hasReachedEnd: hasReachedEnd,
      error: '',
      invoices: oldState.invoices.rebuild((b) => b.addAll(invoices)),
    );
  }
}
