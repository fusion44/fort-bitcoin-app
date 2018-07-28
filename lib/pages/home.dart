/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/pages/receive.dart';
import 'package:mobile_app/pages/send.dart';
import 'stats.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _bottomNavbarIndex = 0;
  Widget _currentPage = StatsPage();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Fort Bitcoin"),
      ),
      body: _currentPage,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavbarIndex,
        onTap: (int index) {
          setState(() {
            _bottomNavbarIndex = index;
            switch (index) {
              case 0:
                _currentPage = StatsPage();
                break;
              case 1:
                _currentPage = SendPage();
                break;
              case 2:
                _currentPage = ReceivePage();
                break;
              default:
                _currentPage = StatsPage();
            }
          });
        },
        items: [
          BottomNavigationBarItem(
              title: const Text("Stats"), icon: const Icon(Icons.home)),
          BottomNavigationBarItem(
              title: const Text("Send"), icon: const Icon(Icons.send)),
          BottomNavigationBarItem(
              title: const Text("Receive"), icon: const Icon(Icons.get_app))
        ],
      ),
    );
  }
}
