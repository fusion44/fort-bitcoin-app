/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/pages/balance.dart';
import 'package:mobile_app/pages/receive.dart';
import 'package:mobile_app/pages/send.dart';
import 'package:mobile_app/pages/stats.dart';
import 'package:mobile_app/routes.dart';
import 'package:mobile_app/widgets/drawer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String appBarText = StatsPage.appBarText;
  Pages _page = Pages.balance;

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_page) {
      case Pages.stats:
        appBarText = StatsPage.appBarText;
        body = StatsPage();
        break;
      case Pages.send:
        appBarText = SendPage.appBarText;
        body = SendPage();
        break;
      case Pages.receive:
        appBarText = ReceivePage.appBarText;
        body = ReceivePage();
        break;
      case Pages.balance:
        appBarText = BalancesPage.appBarText;
        body = BalancesPage();
        break;
      default:
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarText),
      ),
      body: body,
      drawer: FortBtcDrawer((Pages page) {
        setState(() {
          _page = page;
        });
      }),
    );
  }
}
