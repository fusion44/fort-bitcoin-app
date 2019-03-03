/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:bloc/bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/blocs/list_payments/list_payments_bloc_events.dart';
import 'package:mobile_app/blocs/list_payments/list_payments_bloc_state.dart';
import 'package:mobile_app/gql/queries/payments.dart';
import 'package:mobile_app/gql/types/lnpayment.dart';

class ListPaymentsBloc extends Bloc<ListPaymentsEvent, ListPaymentsState> {
  final GraphQLClient _client;
  ListPaymentsBloc(this._client, {bool preload = true}) {
    if (preload) loadPayments();
  }

  ListPaymentsState get initialState => ListPaymentsState.initial();

  loadPayments() {
    dispatch(LoadPayments());
  }

  @override
  Stream<ListPaymentsState> mapEventToState(
      ListPaymentsState state, ListPaymentsEvent event) async* {
    if (event is LoadPayments) {
      yield ListPaymentsState.loading(
          ListPaymentsEventType.startLoading, state);
      yield await _loadPaymentsImpl(state);
    }
  }

  Future<ListPaymentsState> _loadPaymentsImpl(ListPaymentsState state) async {
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
        return ListPaymentsState.success(ListPaymentsEventType.finishLoading,
            payments, (payments.length > 0 ? false : true), state);
      case "ListPaymentsError":
      case "ServerError":
        var errorMessage = result.data["lnListPayments"]["errorMessage"];
        return ListPaymentsState.failure(
            ListPaymentsEventType.failLoading, state, errorMessage);
        break;
      default:
        return ListPaymentsState.failure(ListPaymentsEventType.failLoading,
            state, "Implement me: $typename");
    }
  }
}
