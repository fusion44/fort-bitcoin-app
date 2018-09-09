/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/pages/finance.dart';
import 'package:mobile_app/pages/stats.dart';
import 'package:mobile_app/routes.dart';

class FortBtcDrawer extends StatefulWidget {
  final Function _pageChange;
  FortBtcDrawer(this._pageChange);

  FortBtcDrawerState createState() => FortBtcDrawerState();
}

class FortBtcDrawerState extends State<FortBtcDrawer> {
  bool _showDetails = false;
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Widget drawerHeader = UserAccountsDrawerHeader(
        accountEmail: Text("fake@email.com"),
        accountName: Text(
          "My username",
          style: theme.textTheme.title,
        ),
        onDetailsPressed: () {
          setState(() {
            _showDetails = !_showDetails;
          });
        },
        currentAccountPicture: CircleAvatar(
          backgroundImage: NetworkImage("http://i.pravatar.cc/300"),
        ),
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(
                    "https://placeimg.com/640/480/arch/grayscale"))));

    ListView list;

    if (_showDetails) {
      list = ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[ListTile(title: Text("Logout"))]);
    } else {
      list = ListView(padding: EdgeInsets.zero, children: <Widget>[
        ListTile(
            leading: Icon(FinancePage.icon),
            title: Text(FinancePage.appBarText),
            onTap: () {
              widget._pageChange(DrawerPages.finance);
              Navigator.pop(context);
            }),
        ListTile(
            leading: Icon(StatsPage.icon),
            title: Text(StatsPage.appBarText),
            onTap: () {
              widget._pageChange(DrawerPages.stats);
              Navigator.pop(context);
            }),
      ]);
    }

    return SizedBox(
      width: 280.0,
      child: Container(
        color: theme.backgroundColor,
        child: Column(
          children: <Widget>[
            drawerHeader,
            Expanded(
              child: list,
            ),
            AboutListTile(
              applicationName: "Fort Bitcoin",
            )
          ],
        ),
      ),
    );
  }
}
