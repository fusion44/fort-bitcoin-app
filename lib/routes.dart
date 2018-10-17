/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/pages/home.dart';
import 'package:mobile_app/pages/setup_wallet.dart';
import 'package:mobile_app/pages/signup.dart';
import 'package:mobile_app/pages/splash.dart';

// Pages that have no route. They all reside in /home
// and are switched via drawer or bottom nav bar
enum DrawerPages { finance, connectivity, stats }
enum BottomNavbarPagesFin { balance, send, receive }
enum BottomNavbarPagesConn { channels, peers }

final routes = {
  "/home": (BuildContext context) => new HomePage(),
  "/signup": (BuildContext context) => new SignupPage(),
  "/splash": (BuildContext context) => new SplashPage(),
  "/setup_wallet": (BuildContext context) => new SetupWalletPage(),
};
