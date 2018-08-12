/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';

class ReceivePage extends StatelessWidget {
  static IconData icon = Icons.toll;
  static String appBarText = "Receive";

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Center(
        child: Text(
      "RECEIVE",
      style: theme.textTheme.display1,
    ));
  }
}
