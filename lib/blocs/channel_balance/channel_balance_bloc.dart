/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/blocs/channel_balance/channel_balance.dart';
import 'package:mobile_app/gql/queries/balances.dart';
import 'package:mobile_app/gql/types/lnchannelbalance.dart';

class ChannelBalanceBloc
    extends Bloc<ChannelBalanceEvent, ChannelBalanceState> {
  final GraphQLClient _gqlClient;

  ChannelBalanceBloc(this._gqlClient, [prefetch = true]) {
    if (prefetch) dispatch(LoadChannelBalanceEvent());
  }

  ChannelBalanceState get initialState => ChannelBalanceState.initial();

  @override
  Stream<ChannelBalanceState> mapEventToState(
      ChannelBalanceState state, ChannelBalanceEvent event) async* {
    if (event is LoadChannelBalanceEvent) {
      _updateBalance();
      yield ChannelBalanceState(
          type: ChannelBalanceEventType.startLoading,
          isLoading: true,
          balance: state.balance);
    }

    if (event is ChannelBalanceUpdatedEvent) {
      if (event.error != null) {
        yield ChannelBalanceState.failure(oldState: state, error: event.error);
        return;
      }
      yield ChannelBalanceState(
        type: ChannelBalanceEventType.finishLoading,
        isLoading: false,
        balance: event.balance,
      );
    }
  }

  Future _updateBalance() async {
    QueryResult result = await _gqlClient.query(
      QueryOptions(
        document: lnGetChannelBalance,
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasErrors) {
      for (var err in result.errors) {
        print("_updateInfo: ${err.locations}");
        print("_updateInfo: ${err.message}");
      }
    }

    if (result.data != null) {
      LnChannelBalance balance;
      var data = result.data["lnGetChannelBalance"];

      String typename = data["__typename"];
      switch (typename) {
        case "GetChannelBalanceSuccess":
          balance = LnChannelBalance(data["lnChannelBalance"]);
          dispatch(ChannelBalanceUpdatedEvent(balance: balance));
          break;
        case "WalletInstanceNotRunning":
        case "WalletInstanceNotFound":
          print("$typename");
          break;
        case "GetChannelBalanceError":
        case "ServerError":
          String errorMessage = data["errorMessage"];
          dispatch(ChannelBalanceUpdatedEvent(error: errorMessage));
          break;
        default:
      }
    }
  }
}
