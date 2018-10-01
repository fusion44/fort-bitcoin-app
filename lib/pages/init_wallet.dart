/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';

class InitWalletPage extends StatefulWidget {
  @override
  _InitWalletPageState createState() => _InitWalletPageState();
}

class _InitWalletPageState extends State<InitWalletPage> {
  String appBarText = "Initialize your wallet";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return;
        },
        child: Scaffold(
          appBar: AppBar(
            leading: Container(),
            title: Text(appBarText),
          ),
          body: Text("init wallet here"),
        ));
  }
}
