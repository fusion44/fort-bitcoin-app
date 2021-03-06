/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/connectivity/channels/channel_page.dart';
import 'package:mobile_app/connectivity/info/wallet_info_page.dart';
import 'package:mobile_app/connectivity/peer/peer_page.dart';
import 'package:mobile_app/routes.dart';

class ConnectivityPage extends StatefulWidget {
  static IconData icon = Icons.network_locked;
  static String appBarText = "Connectivity";

  @override
  _ConnectivityPageState createState() => _ConnectivityPageState();
}

class _ConnectivityPageState extends State<ConnectivityPage> {
  int _bottomNavbarIndex = 0;
  BottomNavbarPagesConn _page = BottomNavbarPagesConn.channels;
  List<BottomNavigationBarItem> navItems = [
    BottomNavigationBarItem(
      title: const Text("Channels"),
      icon: const Icon(Icons.show_chart),
    ),
    BottomNavigationBarItem(
      title: const Text("Peers"),
      icon: const Icon(Icons.assistant),
    ),
    BottomNavigationBarItem(
      title: const Text("Info"),
      icon: const Icon(Icons.info),
    ),
  ];

  void nav(int index) {
    setState(() {
      _bottomNavbarIndex = index;
      switch (index) {
        case 0:
          _page = BottomNavbarPagesConn.channels;
          break;
        case 1:
          _page = BottomNavbarPagesConn.peers;
          break;
        case 2:
          _page = BottomNavbarPagesConn.node_info;
          break;
        default:
          _page = BottomNavbarPagesConn.channels;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_page) {
      case BottomNavbarPagesConn.channels:
        body = ChannelPage();
        break;
      case BottomNavbarPagesConn.peers:
        body = PeerPage();
        break;
      case BottomNavbarPagesConn.node_info:
        body = WalletInfoPage();
        break;
      default:
        body = Center(child: Text("implement me $_page"));
    }

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavbarIndex,
        onTap: nav,
        items: navItems,
      ),
    );
  }
}
