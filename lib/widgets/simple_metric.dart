/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';

class SimpleMetricWidget extends StatelessWidget {
  final String _header;
  final String _metric;
  final String _footer;

  SimpleMetricWidget(this._header, this._metric, [this._footer = ""]);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          _header,
          style: TextStyle(fontSize: 20.0),
        ),
        Text(
          _metric,
          style: TextStyle(
              fontSize: 25.0, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        Text(
          _footer,
        )
      ],
    );
  }
}
