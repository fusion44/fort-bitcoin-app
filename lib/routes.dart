/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/auth/wallet/setup_wallet_page.dart';
import 'package:mobile_app/common/pages/home_page.dart';
import 'package:mobile_app/common/pages/splash_page.dart';

// Pages that have no route. They all reside in /home
// and are switched via drawer or bottom nav bar
enum DrawerPages { finance, connectivity, stats, manage_wallet }
enum BottomNavbarPagesFin { balance, send, receive }
enum BottomNavbarPagesConn { channels, peers, node_info }

final routes = {
  "/home": (BuildContext context) => new HomePage(),
  "/splash": (BuildContext context) => new SplashPage(),
  "/setup_wallet": (BuildContext context) => new SetupWalletPage(),
};
