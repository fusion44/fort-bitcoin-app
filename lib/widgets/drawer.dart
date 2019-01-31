/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/auth/auth/authentication.dart';
import 'package:mobile_app/blocs/auth/logout/logout.dart';
import 'package:mobile_app/pages/connectivity.dart';
import 'package:mobile_app/pages/finance.dart';
import 'package:mobile_app/pages/manage_wallet.dart';
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
    AuthenticationBloc authBloc = BlocProvider.of<AuthenticationBloc>(context);

    Widget drawerHeader = UserAccountsDrawerHeader(
      accountEmail: Text(""),
      accountName: Text(
        authBloc.userRepository.user.name,
        style: theme.textTheme.title,
      ),
      onDetailsPressed: () {
        setState(() {
          _showDetails = !_showDetails;
        });
      },
    );

    ListView list;

    if (_showDetails) {
      list = ListView(padding: EdgeInsets.zero, children: <Widget>[
        ListTile(
            title: Text("Logout"),
            onTap: () {
              LogoutBloc lobloc = LogoutBloc(authBloc: authBloc);
              lobloc.dispatch(LogoutButtonPressed());
            })
      ]);
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
            leading: Icon(ConnectivityPage.icon),
            title: Text(ConnectivityPage.appBarText),
            onTap: () {
              widget._pageChange(DrawerPages.connectivity);
              Navigator.pop(context);
            }),
        ListTile(
            leading: Icon(StatsPage.icon),
            title: Text(StatsPage.appBarText),
            onTap: () {
              widget._pageChange(DrawerPages.stats);
              Navigator.pop(context);
            }),
        ListTile(
            leading: Icon(ManageWalletPage.icon),
            title: Text(ManageWalletPage.appBarText),
            onTap: () {
              widget._pageChange(DrawerPages.manage_wallet);
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
