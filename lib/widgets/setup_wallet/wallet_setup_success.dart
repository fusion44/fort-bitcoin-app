/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/gql/queries/system_status.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletSetupSuccessWidget extends StatefulWidget {
  _WalletSetupSuccessWidgetState createState() =>
      _WalletSetupSuccessWidgetState();
}

class _WalletSetupSuccessWidgetState extends State<WalletSetupSuccessWidget> {
  final int genesisBlockTime = 1231006505000;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int timeSinceGenesis =
        DateTime.now().millisecondsSinceEpoch - genesisBlockTime;

    return Container(
      child: Query(
        options: QueryOptions(document: getInfoQuery, pollInterval: 5),
        builder: (QueryResult result) {
          if (result.loading) {
            return Text("");
          }
          if (result.hasErrors) {
            // Show error
            return Text("errros");
          }
          var data = result.data["lnGetInfo"];
          List<Widget> children = [];
          String typename = data["__typename"];
          switch (typename) {
            case "GetInfoSuccess":
              bool syncedToChain = data["lnInfo"]["syncedToChain"];
              if (syncedToChain) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setBool("wallet_is_initialized", true);
                  });

                  Navigator.pushNamedAndRemoveUntil(
                      context, "/home", (_) => false);
                });
              }
              children.add(Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    "Your wallet is catching up with the Bitcoin network.",
                    style: theme.textTheme.headline,
                  )));
              int bestHeaderTimestamp =
                  data["lnInfo"]["bestHeaderTimestamp"] * 1000;
              children.add(LinearProgressIndicator(
                  value: (1 / timeSinceGenesis) *
                      (bestHeaderTimestamp - genesisBlockTime)));

              String date = formatDate(
                  DateTime.fromMillisecondsSinceEpoch(bestHeaderTimestamp),
                  [yy, "-", M, "-", dd, " ", hh, ":", nn]);

              children.add(Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Text(date, style: theme.textTheme.display1)));
              break;
            case "GetInfoError":
              String msg = data["errorMessage"] ?? "No error description";
              children.add(Text("Error while fetching info $msg"));
              break;
            case "WalletInstanceNotFound":
              children.add(Text("Error: no wallet instance found."));
              break;
            case "ServerError":
              String msg = data["errorMessage"] ?? "No error description";
              children.add(Text("Error while fetching info $msg"));
              break;
            default:
          }
          return Padding(
              padding: EdgeInsets.all(20.0), child: Column(children: children));
        },
      ),
    );
  }
}
