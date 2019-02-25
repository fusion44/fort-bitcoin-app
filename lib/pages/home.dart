/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/auth/auth/authentication.dart';
import 'package:mobile_app/blocs/wallet_info/wallet_info.dart';
import 'package:mobile_app/models.dart';
import 'package:mobile_app/pages/connectivity.dart';
import 'package:mobile_app/pages/finance.dart';
import 'package:mobile_app/pages/manage_wallet.dart';
import 'package:mobile_app/pages/stats.dart';
import 'package:mobile_app/routes.dart';
import 'package:mobile_app/widgets/drawer.dart';
import 'package:mobile_app/widgets/wallet_sync_progress.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String appBarText = StatsPage.appBarText;
  DrawerPages _drawerPage = DrawerPages.finance;

  bool _pollIntervallWasDispatched = false;

  @override
  Widget build(BuildContext context) {
    AuthenticationBloc bloc = BlocProvider.of<AuthenticationBloc>(context);
    Widget body;

    if (bloc.userRepository.user.walletState == WalletState.notRunning) {
      _drawerPage = DrawerPages.manage_wallet;
    }

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
      case DrawerPages.manage_wallet:
        appBarText = ManageWalletPage.appBarText;
        body = ManageWalletPage();
        break;
      default:
    }

    WalletInfoBloc walletInfoBloc = BlocProvider.of<WalletInfoBloc>(context);
    if (!_pollIntervallWasDispatched) {
      // If we are synced, the BLOC will turn the polling off automatically
      // after the first update. We activate it once to make sure we check
      // the sync state at least once.
      walletInfoBloc.dispatch(
        UpdatePollintervallEvent(
          pollIntervallSeconds: Duration(seconds: 7),
        ),
      );
      _pollIntervallWasDispatched = true;
    }

    return BlocBuilder(
      bloc: walletInfoBloc,
      builder: (BuildContext context, WalletInfoState state) {
        var appBarBottom;
        if (!state.loading) {
          appBarBottom =
              state.info.syncedToChain ? null : WalletSyncProgressWidget(state);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(appBarText),
            bottom: appBarBottom,
          ),
          body: body,
          drawer: FortBtcDrawer((DrawerPages page) {
            setState(() {
              _drawerPage = page;
            });
          }),
        );
      },
    );
  }
}
