/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:bloc/bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/balance/onchain_data/onchain_data_bloc_events.dart';
import 'package:mobile_app/balance/onchain_data/onchain_data_bloc_state.dart';
import 'package:mobile_app/common/types/lntransaction.dart';
import 'package:mobile_app/common/types/lnwalletbalance.dart';

String getOnchainFinanceInfo = """
query getOnchainFinanceInfo {
  lnGetTransactions {
    __typename
    ... on GetTransactionsSuccess {
      lnTransactionDetails {
        transactions {
          amount
          timeStamp
          totalFees
          destAddresses
        }
      }
    }
    ... on ServerError {
      errorMessage
    }
  }
  lnGetWalletBalance {
    __typename
    ... on GetWalletBalanceSuccess {
      lnWalletBalance {
        totalBalance
        confirmedBalance
        unconfirmedBalance
      }
    }
    ... on ServerError {
      errorMessage
    }
  }
}
""";

class OnchainDataBloc extends Bloc<OnchainDataEvent, OnchainDataState> {
  final GraphQLClient _client;
  bool _loading = false;

  OnchainDataBloc(this._client, {bool preload = true}) {
    if (preload) dispatch(LoadOnchainData());
  }

  OnchainDataState get initialState => OnchainDataState.initial();

  @override
  Stream<OnchainDataState> mapEventToState(
      OnchainDataState state, OnchainDataEvent event) async* {
    if (event is LoadOnchainData && !_loading) {
      yield OnchainDataState.loading(OnchainDataEventType.startLoading, state);
      yield await _loadDataImpl(state);
    }
  }

  Future<OnchainDataState> _loadDataImpl(OnchainDataState state) async {
    _loading = true;
    QueryResult result = await _client.query(
      QueryOptions(
        fetchPolicy: FetchPolicy.networkOnly,
        document: getOnchainFinanceInfo,
      ),
    );

    LnWalletBalance balance;
    List<String> errors = [];

    var typename = result.data["lnGetWalletBalance"]["__typename"];
    switch (typename) {
      case "GetWalletBalanceSuccess":
        var bal = result.data["lnGetWalletBalance"]["lnWalletBalance"];
        balance = LnWalletBalance(bal);
        break;
      case "GetWalletBalanceError":
        errors.add(result.data["lnGetWalletBalance"]["lnWalletBalance"]
            ["errorMessage"]);
        break;
      case "Unauthenticated":
      case "ServerError":
      case "WalletInstanceNotFound":
      case "WalletInstanceNotRunning":
        errors.add("An error occured while fetching the wallet balance");
        break;
      default:
    }

    typename = result.data["lnGetTransactions"]["__typename"];
    List transactionData;
    switch (typename) {
      case "GetTransactionsSuccess":
        var data = result.data["lnGetTransactions"]["lnTransactionDetails"];
        transactionData = data["transactions"];
        break;
      case "GetTransactionsError":
        errors.add(result.data["lnGetTransactions"]["lnTransactionDetails"]
            ["errorMessage"]);
        break;
      case "Unauthenticated":
      case "ServerError":
      case "WalletInstanceNotFound":
      case "WalletInstanceNotRunning":
        errors.add("An error occured while fetching transactions");
        break;
      default:
    }

    String errorMessage = "";
    if (errors.length > 0) {
      for (int i = 0; i < errors.length; i++) {
        if (i + 1 == errors.length) {
          errorMessage += errors[i];
        } else {
          errorMessage += errors[i] + "\n";
        }
      }

      _loading = false;
      return OnchainDataState.failure(
          OnchainDataEventType.failLoading, state, errorMessage);
    }

    List<LnTransaction> txList =
        transactionData.map((tx) => LnTransaction(tx)).toList();

    // Sort all transactions by creation date so the newest
    // transactions is shown first
    txList.sort((first, second) => second.timeStamp.compareTo(first.timeStamp));
    _loading = false;
    return OnchainDataState.success(OnchainDataEventType.finishLoading, txList,
        balance, true, OnchainDataState.initial());
  }
}
