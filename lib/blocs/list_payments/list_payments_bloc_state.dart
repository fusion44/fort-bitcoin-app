/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:meta/meta.dart';
import 'package:mobile_app/blocs/list_payments/list_payments_bloc_events.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mobile_app/gql/types/lnpayment.dart';

class ListPaymentsState {
  final ListPaymentsEventType type;
  final bool isLoading;
  final bool hasReachedEnd;
  final String error;
  final BuiltList<LnPayment> payments;

  const ListPaymentsState({
    @required this.type,
    @required this.isLoading,
    @required this.hasReachedEnd,
    @required this.error,
    @required this.payments,
  });

  factory ListPaymentsState.initial() {
    return ListPaymentsState(
      type: ListPaymentsEventType.initial,
      isLoading: true,
      hasReachedEnd: false,
      error: '',
      payments: new BuiltList<LnPayment>(),
    );
  }

  factory ListPaymentsState.loading(
      ListPaymentsEventType type, ListPaymentsState oldState) {
    return ListPaymentsState(
      type: type,
      isLoading: true,
      hasReachedEnd: oldState.hasReachedEnd,
      error: oldState.error,
      payments: oldState.payments,
    );
  }

  factory ListPaymentsState.failure(
      ListPaymentsEventType type, ListPaymentsState oldState, String error) {
    return ListPaymentsState(
      type: type,
      isLoading: oldState.isLoading,
      hasReachedEnd: oldState.hasReachedEnd,
      error: error,
      payments: oldState.payments,
    );
  }

  factory ListPaymentsState.success(
      ListPaymentsEventType type,
      List<LnPayment> payments,
      bool hasReachedEnd,
      ListPaymentsState oldState) {
    return ListPaymentsState(
      type: type,
      isLoading: false,
      hasReachedEnd: hasReachedEnd,
      error: '',
      payments: oldState.payments.rebuild((b) => b.addAll(payments)),
    );
  }
}
