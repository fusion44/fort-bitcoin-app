/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';

class SimpleDataRowWidget extends StatelessWidget {
  final dynamic left;
  final dynamic right;
  const SimpleDataRowWidget({
    Key key,
    @required this.left,
    @required this.right,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            left.toString(),
            textAlign: TextAlign.end,
          ),
        ),
        Container(
          width: 20.0,
        ),
        Expanded(
          child: Text(
            right.toString(),
            style: theme.textTheme.body2,
          ),
        )
      ],
    );
  }
}
