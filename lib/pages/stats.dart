/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/models.dart';
import 'package:mobile_app/widgets/card_error.dart';
import 'package:mobile_app/widgets/card_node_stats.dart';
import 'package:mobile_app/widgets/card_bitcoind_stats.dart';
import 'package:mobile_app/widgets/card_lnd_stats.dart';
import '../gql/queries/system_status.dart' as sysStatusQueries;

class StatsPage extends StatefulWidget {
  static final IconData icon = Icons.show_chart;
  static final String appBarText = "Node Stats";

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final String _localErrorKey = "local_error";
  bool _loading = true;
  Map<String, dynamic> _data;
  GraphQLClient _client;
  Map<String, DataFetchError> _errorMessages = Map();

  @override
  void didChangeDependencies() {
    _client = GraphQLProvider.of(context).value;
    _fetchData();
    super.didChangeDependencies();
  }

  Map<String, DataFetchError> _processGraphqlErrors(data) {
    Map<String, DataFetchError> errors = Map();

    if (data.containsKey("errors")) {
      for (var error in data["errors"]) {
        int code;
        String message;
        jsonDecode(error["message"], reviver: (k, v) {
          if (k == "code") {
            code = v;
          } else if (k == "message") {
            message = v;
          }
        });
        DataFetchError err = DataFetchError(code, message, error["path"][0]);
        errors[err.path] = err;
      }
    }

    return errors;
  }

  void _processData(Map<String, dynamic> data) {
    if (this.mounted) {
      Map<String, DataFetchError> errs = _processGraphqlErrors(data);
      setState(() {
        _errorMessages = errs;
        _loading = false;
        _data = data;
      });
    }
  }

  Future _fetchData() async {
    //reset old error messages
    _errorMessages = Map();
    try {
      QueryResult result = await _client.query(QueryOptions(
          document: sysStatusQueries.getSystemStatus,
          fetchPolicy: FetchPolicy.networkOnly));
      _processData(result.data);
    } catch (error) {
      // Process client errors like 404's
      DataFetchError err = DataFetchError(-1, error.toString(), _localErrorKey);
      _errorMessages[_localErrorKey] = err;
      print(error);
    }
  }

  bool hasError(List<String> keys) {
    for (String key in keys) {
      if (_errorMessages.containsKey(key)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessages.isNotEmpty) {
      return new ErrorDisplayCard("Error", _errorMessages.values);
    }

    if (_loading) {
      return ListView(
        children: <Widget>[
          CardNodeStats(_loading),
          CardBitcoindStats(_loading, false),
          CardBitcoindStats(_loading, true)
        ],
      );
    } else {
      return RefreshIndicator(
          onRefresh: () async {
            await _fetchData();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              hasError(["systemstatus"])
                  ? ErrorDisplayCard(
                      "System Health", [_errorMessages["systemstatus"]])
                  : CardNodeStats(
                      _loading,
                      _data["systemstatus"]["uptime"],
                      _data["systemstatus"]["cpuLoad"],
                      _data["systemstatus"]["memoryUsed"],
                      _data["systemstatus"]["memoryTotal"],
                      _data["systemstatus"]["trafficIn"],
                      _data["systemstatus"]["trafficOut"]),
              hasError(["mainnetblocks", "mainnetnetwork"])
                  ? ErrorDisplayCard(
                      "Bitcoind Mainnet", [_errorMessages["systemstatus"]])
                  : CardBitcoindStats(
                      _loading,
                      false,
                      _data["mainnetblocks"]["blocks"],
                      _data["mainnetnetwork"]["subversion"],
                      _data["mainnetnetwork"]["connections"],
                      _data["mainnetnetwork"]["warnings"],
                    ),
              hasError(["testnetblocks", "testnetnetwork"])
                  ? ErrorDisplayCard(
                      "Bitcoind Testnet", [_errorMessages["testnetblocks"]])
                  : CardBitcoindStats(
                      _loading,
                      true,
                      _data["testnetblocks"]["blocks"],
                      _data["testnetnetwork"]["subversion"],
                      _data["testnetnetwork"]["connections"],
                      _data["testnetnetwork"]["warnings"],
                    ),
              hasError(["lnGetInfo"])
                  ? ErrorDisplayCard("Lightning", [_errorMessages["lnGetInfo"]])
                  : CardLndStats(
                      _loading,
                      _data["lnGetInfo"]["lnInfo"]["testnet"],
                      _data["lnGetInfo"]["lnInfo"]["alias"],
                      _data["lnGetInfo"]["lnInfo"]["blockHeight"],
                      _data["lnGetInfo"]["lnInfo"]["identityPubkey"],
                      _data["lnGetInfo"]["lnInfo"]["numActiveChannels"],
                      _data["lnGetInfo"]["lnInfo"]["numInactiveChannels"],
                      _data["lnGetInfo"]["lnInfo"]["numPendingChannels"],
                      _data["lnGetInfo"]["lnInfo"]["numPeers"],
                      _data["lnGetInfo"]["lnInfo"]["syncedToChain"],
                      _data["lnGetInfo"]["lnInfo"]["version"],
                    ),
            ],
          ));
    }
  }
}
