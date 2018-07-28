/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';

class SendPage extends StatefulWidget {
  SendPage({Key key}) : super(key: key);

  @override
  _SendPageState createState() => new _SendPageState();
}

class _SendPageState extends State<SendPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(child: Text("Send")),
    );
  }
}
