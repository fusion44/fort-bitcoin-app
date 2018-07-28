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
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  Widget build(BuildContext context) {
    return new Query(
      sysStatusQueries.getSystemStatus,
      pollInterval: 15,
      builder: ({
        bool loading,
        Map data,
        String error,
      }) {
        if (error != '') {
          return new Text(error);
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
          var sys = data["systemstatus"];

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
                data["mainnetblocks"]["blocks"],
                data["mainnetnetwork"]["subversion"],
                data["mainnetnetwork"]["connections"],
                data["mainnetnetwork"]["warnings"],
              ),
              CardLndStats(
                loading,
                false,
                data["mainnetln"]["alias"],
                data["mainnetln"]["blockHeight"],
                data["mainnetln"]["identityPubkey"],
                data["mainnetln"]["numActiveChannels"],
                data["mainnetln"]["numPeers"],
                data["mainnetln"]["syncedToChain"],
                data["mainnetln"]["version"],
              ),
              CardBitcoindStats(
                loading,
                true,
                data["testnetblocks"]["blocks"],
                data["testnetnetwork"]["subversion"],
                data["testnetnetwork"]["connections"],
                data["testnetnetwork"]["warnings"],
              ),
              CardLndStats(
                loading,
                false,
                data["testnetln"]["alias"],
                data["testnetln"]["blockHeight"],
                data["testnetln"]["identityPubkey"],
                data["testnetln"]["numActiveChannels"],
                data["testnetln"]["numPeers"],
                data["testnetln"]["syncedToChain"],
                data["testnetln"]["version"],
              ),
            ],
          );
        }
      },
    );
  }
}
