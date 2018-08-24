/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/card_lightning_balance.dart';
import 'package:mobile_app/widgets/card_onchain_balance.dart';

class BalancesPage extends StatelessWidget {
  static IconData icon = Icons.all_inclusive;
  static String appBarText = "Balances";

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      CardLightningBalance(true),
      CardOnchainBalance(true),
      CardLightningBalance(false),
      CardOnchainBalance(false),
    ];

    return RefreshIndicator(
        onRefresh: () async {
          print("TODO: Refresh");
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: children,
        ));
  }
}
