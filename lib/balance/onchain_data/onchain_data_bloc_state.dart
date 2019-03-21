/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:meta/meta.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mobile_app/balance/onchain_data/onchain_data_bloc_events.dart';
import 'package:mobile_app/common/types/lntransaction.dart';
import 'package:mobile_app/common/types/lnwalletbalance.dart';

class OnchainDataState {
  final OnchainDataEventType type;
  final bool isLoading;
  final bool hasReachedEnd;
  final String error;
  final LnWalletBalance balance;
  final BuiltList<LnTransaction> transactions;

  const OnchainDataState({
    @required this.type,
    @required this.isLoading,
    @required this.hasReachedEnd,
    @required this.error,
    @required this.balance,
    @required this.transactions,
  });

  factory OnchainDataState.initial() {
    return OnchainDataState(
      type: OnchainDataEventType.initial,
      isLoading: true,
      hasReachedEnd: false,
      error: '',
      balance: LnWalletBalance({}),
      transactions: new BuiltList<LnTransaction>(),
    );
  }

  factory OnchainDataState.loading(
      OnchainDataEventType type, OnchainDataState oldState) {
    return OnchainDataState(
      type: type,
      isLoading: true,
      hasReachedEnd: oldState.hasReachedEnd,
      error: oldState.error,
      balance: oldState.balance,
      transactions: oldState.transactions,
    );
  }

  factory OnchainDataState.failure(
      OnchainDataEventType type, OnchainDataState oldState, String error) {
    return OnchainDataState(
      type: type,
      isLoading: oldState.isLoading,
      hasReachedEnd: oldState.hasReachedEnd,
      error: error,
      balance: oldState.balance,
      transactions: oldState.transactions,
    );
  }

  factory OnchainDataState.success(
      OnchainDataEventType type,
      List<LnTransaction> transactions,
      LnWalletBalance balance,
      bool hasReachedEnd,
      OnchainDataState oldState) {
    return OnchainDataState(
      type: type,
      isLoading: false,
      hasReachedEnd: hasReachedEnd,
      error: '',
      balance: balance,
      transactions:
          oldState.transactions.rebuild((b) => b.addAll(transactions)),
    );
  }
}
