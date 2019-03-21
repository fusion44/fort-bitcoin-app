/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:bloc/bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/balance/payment/list_payment_bloc_events.dart';
import 'package:mobile_app/balance/payment/list_payment_bloc_state.dart';
import 'package:mobile_app/common/types/lnpayment.dart';

String listPayments = """
query ListPayments(\$indexOffset: Int, \$numMaxPayments: Int, \$reverse: Boolean) {
  lnListPayments(indexOffset: \$indexOffset, numMaxPayments: \$numMaxPayments, reverse: \$reverse) {
    __typename
    ... on ListPaymentsSuccess {
      payments {
        paymentHash
        value
        creationDate
        path
        fee
        paymentPreimage
      }
    }
    ... on ServerError {
      errorMessage
    }
    ... on ListPaymentsError {
      errorMessage
    }
  }
}
""";

class ListPaymentBloc extends Bloc<PaymentEvent, ListPaymentState> {
  final GraphQLClient _client;
  ListPaymentBloc(this._client, {bool preload = true}) {
    if (preload) loadPayments();
  }

  ListPaymentState get initialState => ListPaymentState.initial();

  loadPayments() {
    dispatch(LoadPayments());
  }

  @override
  Stream<ListPaymentState> mapEventToState(
      ListPaymentState state, PaymentEvent event) async* {
    if (event is LoadPayments) {
      yield ListPaymentState.loading(ListPaymentEventType.startLoading, state);
      yield await _loadPaymentsImpl(state);
    }
  }

  Future<ListPaymentState> _loadPaymentsImpl(ListPaymentState state) async {
    QueryResult result = await _client.query(QueryOptions(
        variables: {"numMaxPayments": 15, "indexOffset": state.payments.length},
        fetchPolicy: FetchPolicy.networkOnly,
        document: listPayments));

    String typename = result.data["lnListPayments"]["__typename"];
    switch (typename) {
      case "ListPaymentsSuccess":
        List<LnPayment> payments = [];
        for (Map payment in result.data["lnListPayments"]["payments"]) {
          payments.add(LnPayment(payment));
        }
        payments.sort((a, b) => -a.creationDate.compareTo(b.creationDate));
        return ListPaymentState.success(ListPaymentEventType.finishLoading,
            payments, (payments.length > 0 ? false : true), state);
      case "ListPaymentsError":
      case "ServerError":
        var errorMessage = result.data["lnListPayments"]["errorMessage"];
        return ListPaymentState.failure(
            ListPaymentEventType.failLoading, state, errorMessage);
        break;
      default:
        return ListPaymentState.failure(
            ListPaymentEventType.failLoading, state, "Implement me: $typename");
    }
  }
}
