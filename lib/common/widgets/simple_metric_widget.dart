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
    ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          _header,
          style: theme.textTheme.subhead,
        ),
        Text(
          _metric,
          style: theme.textTheme.display1,
        ),
        Text(
          _footer,
          style: theme.textTheme.caption,
        )
      ],
    );
  }
}
