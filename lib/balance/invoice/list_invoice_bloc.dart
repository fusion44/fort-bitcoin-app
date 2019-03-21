/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:bloc/bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/balance/invoice/list_invoice_bloc_events.dart';
import 'package:mobile_app/balance/invoice/list_invoice_bloc_state.dart';
import 'package:mobile_app/common/types/lninvoice.dart';

String listInvoices = """
query ListInvoices(\$pendingOnly: Boolean, \$indexOffset: Int, \$numMaxInvoices: Int, \$reverse: Boolean) {
  lnListInvoices(pendingOnly: \$pendingOnly, indexOffset: \$indexOffset, numMaxInvoices: \$numMaxInvoices, reverse: \$reverse) {
    __typename
    ... on ListInvoicesSuccess {
      invoices {
        memo
        receipt
        rPreimage
        rHash
        value
        settled
        creationDate
        settleDate
        paymentRequest
        descriptionHash
        expiry
        fallbackAddr
        cltvExpiry
        routeHints {
          nodeId
          chanId
          feeBaseMsat
          feeProportionalMillionths
          cltvExpiryDelta
        }
        private
        addIndex
        addIndex
        settleIndex
        amtPaid
      }
      lastIndexOffset
      firstIndexOffset
    }
    ... on ServerError {
      errorMessage
    }
    ... on ListInvoicesError {
      errorMessage
    }
  }
}
""";

class ListInvoiceBloc extends Bloc<ListInvoiceEvent, ListInvoicesState> {
  final GraphQLClient _client;
  ListInvoiceBloc(this._client, {bool preload = true}) {
    if (preload) loadInvoices();
  }

  ListInvoicesState get initialState => ListInvoicesState.initial();

  loadInvoices() {
    dispatch(LoadInvoices());
  }

  @override
  Stream<ListInvoicesState> mapEventToState(
      ListInvoicesState state, ListInvoiceEvent event) async* {
    if (event is LoadInvoices) {
      yield ListInvoicesState.loading(ListInvoiceEventType.startLoading, state);
      yield await _loadInvoicesImpl(state);
    }
  }

  Future<ListInvoicesState> _loadInvoicesImpl(ListInvoicesState state) async {
    QueryResult result = await _client.query(QueryOptions(
        variables: {"numMaxInvoices": 15, "indexOffset": state.invoices.length},
        fetchPolicy: FetchPolicy.networkOnly,
        document: listInvoices));

    String typename = result.data["lnListInvoices"]["__typename"];
    switch (typename) {
      case "ListInvoicesSuccess":
        List<LnInvoice> invoices = [];
        for (Map invoice in result.data["lnListInvoices"]["invoices"]) {
          invoices.add(LnInvoice(invoice));
        }
        invoices.sort((a, b) => -a.addIndex.compareTo(b.addIndex));
        return ListInvoicesState.success(ListInvoiceEventType.finishLoading,
            invoices, (invoices.length > 0 ? false : true), state);
      case "ListInvoicesError":
      case "ServerError":
        var errorMessage = result.data["lnListInvoices"]["errorMessage"];
        return ListInvoicesState.failure(
            ListInvoiceEventType.failLoading, state, errorMessage);
        break;
      default:
        return ListInvoicesState.failure(
            ListInvoiceEventType.failLoading, state, "Implement me: $typename");
    }
  }
}
