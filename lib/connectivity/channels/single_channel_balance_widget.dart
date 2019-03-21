/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';

class SingleChannelBalanceWidget extends StatelessWidget {
  final int _localBalance;
  final int _remoteBalance;

  SingleChannelBalanceWidget(this._localBalance, this._remoteBalance);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    var val = (1 / (_localBalance + _remoteBalance)) * _localBalance;
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Text(
            _localBalance.toString(),
            style: theme.textTheme.body2,
          ),
        ),
        Expanded(flex: 2, child: LinearProgressIndicator(value: val)),
        Expanded(
          flex: 1,
          child: Text(
            _remoteBalance.toString(),
            textAlign: TextAlign.right,
            style: theme.textTheme.body2,
          ),
        )
      ],
    );
  }
}
