/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:meta/meta.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mobile_app/balance/payment/list_payment_bloc_events.dart';
import 'package:mobile_app/common/types/lnpayment.dart';

class ListPaymentState {
  final ListPaymentEventType type;
  final bool isLoading;
  final bool hasReachedEnd;
  final String error;
  final BuiltList<LnPayment> payments;

  const ListPaymentState({
    @required this.type,
    @required this.isLoading,
    @required this.hasReachedEnd,
    @required this.error,
    @required this.payments,
  });

  factory ListPaymentState.initial() {
    return ListPaymentState(
      type: ListPaymentEventType.initial,
      isLoading: true,
      hasReachedEnd: false,
      error: '',
      payments: new BuiltList<LnPayment>(),
    );
  }

  factory ListPaymentState.loading(
      ListPaymentEventType type, ListPaymentState oldState) {
    return ListPaymentState(
      type: type,
      isLoading: true,
      hasReachedEnd: oldState.hasReachedEnd,
      error: oldState.error,
      payments: oldState.payments,
    );
  }

  factory ListPaymentState.failure(
      ListPaymentEventType type, ListPaymentState oldState, String error) {
    return ListPaymentState(
      type: type,
      isLoading: oldState.isLoading,
      hasReachedEnd: oldState.hasReachedEnd,
      error: error,
      payments: oldState.payments,
    );
  }

  factory ListPaymentState.success(ListPaymentEventType type,
      List<LnPayment> payments, bool hasReachedEnd, ListPaymentState oldState) {
    return ListPaymentState(
      type: type,
      isLoading: false,
      hasReachedEnd: hasReachedEnd,
      error: '',
      payments: oldState.payments.rebuild((b) => b.addAll(payments)),
    );
  }
}
