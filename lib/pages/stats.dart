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
  Client _client;
  Map<String, DataFetchError> _errorMessages = Map();

  @override
  void didChangeDependencies() {
    _client = GraphqlProvider.of(context).value;
    _fetchData().then((data) {
      _processData(data);
    }).catchError((error) {
      // Process client errors like 404's
      DataFetchError err = DataFetchError(-1, error.toString(), _localErrorKey);
      _errorMessages[_localErrorKey] = err;
      print(error);
    });
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

  Future<Map<String, dynamic>> _fetchData() {
    _errorMessages = Map();
    return _client.query(query: sysStatusQueries.getSystemStatus);
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
    if (_errorMessages.containsKey(_localErrorKey)) {
      return new ErrorDisplayCard("Error", _errorMessages[_localErrorKey]);
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
      var resp = _data["data"];
      var sys = resp["systemstatus"];

      return RefreshIndicator(
          onRefresh: () async {
            try {
              var data = await _fetchData();
              _processData(data);
              return null;
            } catch (error) {
              print(error);
              return null;
            }
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              hasError(["systemstatus"])
                  ? ErrorDisplayCard(
                      "System Health", _errorMessages["systemstatus"])
                  : CardNodeStats(
                      _loading,
                      sys["uptime"],
                      sys["cpuLoad"],
                      sys["memoryUsed"],
                      sys["memoryTotal"],
                      sys["trafficIn"],
                      sys["trafficOut"]),
              hasError(["mainnetblocks", "mainnetnetwork"])
                  ? ErrorDisplayCard(
                      "Bitcoind Mainnet", _errorMessages["systemstatus"])
                  : CardBitcoindStats(
                      _loading,
                      false,
                      resp["mainnetblocks"]["blocks"],
                      resp["mainnetnetwork"]["subversion"],
                      resp["mainnetnetwork"]["connections"],
                      resp["mainnetnetwork"]["warnings"],
                    ),
              hasError(["mainnetln"])
                  ? ErrorDisplayCard(
                      "Lightning Mainnet", _errorMessages["mainnetln"])
                  : CardLndStats(
                      _loading,
                      false,
                      resp["mainnetln"]["alias"],
                      resp["mainnetln"]["blockHeight"],
                      resp["mainnetln"]["identityPubkey"],
                      resp["mainnetln"]["numActiveChannels"],
                      resp["mainnetln"]["numPeers"],
                      resp["mainnetln"]["syncedToChain"],
                      resp["mainnetln"]["version"],
                    ),
              hasError(["testnetblocks", "testnetnetwork"])
                  ? ErrorDisplayCard(
                      "Bitcoind Testnet", _errorMessages["testnetblocks"])
                  : CardBitcoindStats(
                      _loading,
                      true,
                      resp["testnetblocks"]["blocks"],
                      resp["testnetnetwork"]["subversion"],
                      resp["testnetnetwork"]["connections"],
                      resp["testnetnetwork"]["warnings"],
                    ),
              hasError(["testnetln"])
                  ? ErrorDisplayCard(
                      "Lightning Testnet", _errorMessages["testnetln"])
                  : CardLndStats(
                      _loading,
                      true,
                      resp["testnetln"]["alias"],
                      resp["testnetln"]["blockHeight"],
                      resp["testnetln"]["identityPubkey"],
                      resp["testnetln"]["numActiveChannels"],
                      resp["testnetln"]["numPeers"],
                      resp["testnetln"]["syncedToChain"],
                      resp["testnetln"]["version"],
                    ),
            ],
          ));
    }
  }
}
