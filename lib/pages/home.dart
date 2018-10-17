/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/pages/connectivity.dart';
import 'package:mobile_app/pages/finance.dart';
import 'package:mobile_app/pages/stats.dart';
import 'package:mobile_app/routes.dart';
import 'package:mobile_app/widgets/drawer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String appBarText = StatsPage.appBarText;
  DrawerPages _drawerPage = DrawerPages.connectivity;

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_drawerPage) {
      case DrawerPages.finance:
        appBarText = FinancePage.appBarText;
        body = FinancePage();
        break;
      case DrawerPages.connectivity:
        appBarText = ConnectivityPage.appBarText;
        body = ConnectivityPage();
        break;
      case DrawerPages.stats:
        appBarText = StatsPage.appBarText;
        body = StatsPage();
        break;
      default:
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarText),
      ),
      body: body,
      drawer: FortBtcDrawer((DrawerPages page) {
        setState(() {
          _drawerPage = page;
        });
      }),
    );
  }
}
