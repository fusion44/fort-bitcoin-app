/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/common/types/lninfo.dart';
import 'package:mobile_app/connectivity/info/wallet_info.dart';

String getInfoQuery = """
{
  lnGetInfo {
    __typename
    ... on GetInfoSuccess {
      lnInfo {
        currentIp
        currentPort
        identityPubkey
        alias
        numPendingChannels
        numActiveChannels
        numPeers
        blockHeight
        blockHash
        syncedToChain
        testnet
        bestHeaderTimestamp
        version
      }
    }
    ... on ServerError{ 
      errorMessage
    }
  }
}
""";

class WalletInfoBloc extends Bloc<WalletInfoEvent, WalletInfoState> {
  final GraphQLClient _gqlClient;
  Duration _pollInterval;
  Timer _timer;

  WalletInfoBloc(this._gqlClient, [prefetch = true]) {
    if (prefetch) dispatch(UpdateWalletInfoEvent());
  }

  void _timedUpdate(Timer timer) {
    _updateInfo();
  }

  void _cancelTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
      _pollInterval = null;
    }
  }

  WalletInfoState get initialState => WalletInfoState.initial();

  @override
  Stream<WalletInfoState> mapEventToState(
      WalletInfoState state, WalletInfoEvent event) async* {
    if (event is UpdateWalletInfoEvent) {
      _updateInfo();
      yield WalletInfoState(
        loading: true,
        status: state.status,
        info: state.info,
        autoupdate: state.autoupdate,
        pollIntervall: state.pollIntervall,
      );
    }

    if (event is WalletInfoUpdatedEvent) {
      var autoupdate = state.autoupdate;
      var pollIntervall = state.pollIntervall;

      if (event.info.syncedToChain &&
          _pollInterval != null &&
          _pollInterval.inSeconds != null) {
        _cancelTimer();
        autoupdate = false;
        pollIntervall = null;
      }

      yield WalletInfoState(
        loading: false,
        status: event.status,
        info: event.info,
        autoupdate: autoupdate,
        pollIntervall: pollIntervall,
      );
    }

    if (event is UpdatePollintervallEvent) {
      if (event.pollIntervallSeconds == null &&
          event.pollIntervallSeconds.inSeconds == 0) {
        _cancelTimer();
      } else {
        if (_pollInterval != null &&
            _pollInterval.inSeconds == event.pollIntervallSeconds.inSeconds) {
          return;
        }

        _cancelTimer();
        _pollInterval = event.pollIntervallSeconds;
        _timer = Timer.periodic(event.pollIntervallSeconds, this._timedUpdate);
      }
    }
  }

  Future _updateInfo() async {
    QueryResult result = await _gqlClient.query(
      QueryOptions(
        document: getInfoQuery,
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
      LnInfoType info;
      var data = result.data["lnGetInfo"];

      String typename = data["__typename"];
      switch (typename) {
        case "GetInfoSuccess":
          info = LnInfoType(data["lnInfo"]);
          dispatch(
            WalletInfoUpdatedEvent(
              status: WalletStatus.locked,
              info: info,
            ),
          );
          break;
        case "GetInfoError":
          _cancelTimer();
          print("Error");
          break;
        case "WalletInstanceNotRunning":
        case "WalletInstanceNotFound":
          print("Error: $typename");
          // If there was an error, make sure that the timer is stopped
          // In these two cases we can ommit an error message to the user.
          // The system should show the manage wallet screen now automatically
          _cancelTimer();
          break;
        case "ServerError":
          // TODO:  Check severety and decide whether to show the error to the user
          _cancelTimer();
          break;
        default:
      }
    }
  }
}
