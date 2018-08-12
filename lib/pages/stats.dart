/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
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
  @override
  Widget build(BuildContext context) {
    return Query(
      sysStatusQueries.getSystemStatus,
      pollInterval: 15,
      builder: ({
        bool loading,
        Map data,
        Exception error,
      }) {
        if (error != null) {
          return new Text(error.toString());
        }

        if (loading) {
          return ListView(
            children: <Widget>[
              CardNodeStats(loading),
              CardBitcoindStats(loading, false),
              CardBitcoindStats(loading, true)
            ],
          );
        } else {
          var resp = data["data"];
          var sys = resp["systemstatus"];

          return ListView(
            children: <Widget>[
              CardNodeStats(
                  loading,
                  sys["uptime"],
                  sys["cpuLoad"],
                  sys["memoryUsed"],
                  sys["memoryTotal"],
                  sys["trafficIn"],
                  sys["trafficOut"]),
              CardBitcoindStats(
                loading,
                false,
                resp["mainnetblocks"]["blocks"],
                resp["mainnetnetwork"]["subversion"],
                resp["mainnetnetwork"]["connections"],
                resp["mainnetnetwork"]["warnings"],
              ),
              CardLndStats(
                loading,
                false,
                resp["mainnetln"]["alias"],
                resp["mainnetln"]["blockHeight"],
                resp["mainnetln"]["identityPubkey"],
                resp["mainnetln"]["numActiveChannels"],
                resp["mainnetln"]["numPeers"],
                resp["mainnetln"]["syncedToChain"],
                resp["mainnetln"]["version"],
              ),
              CardBitcoindStats(
                loading,
                true,
                resp["testnetblocks"]["blocks"],
                resp["testnetnetwork"]["subversion"],
                resp["testnetnetwork"]["connections"],
                resp["testnetnetwork"]["warnings"],
              ),
              CardLndStats(
                loading,
                false,
                resp["testnetln"]["alias"],
                resp["testnetln"]["blockHeight"],
                resp["testnetln"]["identityPubkey"],
                resp["testnetln"]["numActiveChannels"],
                resp["testnetln"]["numPeers"],
                resp["testnetln"]["syncedToChain"],
                resp["testnetln"]["version"],
              ),
            ],
          );
        }
      },
    );
  }
}
