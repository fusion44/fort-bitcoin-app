/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/models.dart';
import 'package:mobile_app/widgets/card_base.dart';

/// A card to display an error
/// Displays and error icon and the error text
/// in the theme error colors
class ErrorDisplayCard extends StatelessWidget {
  final String _header;
  final DataFetchError _error;

  ErrorDisplayCard(this._header, this._error);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return CardBase(
        _header,
        Column(children: <Widget>[
          Icon(
            Icons.error,
            size: 75.0,
            color: theme.errorColor,
          ),
          Text(
            _error.message,
            style: TextStyle(color: theme.errorColor, fontSize: 25.0),
          )
        ]));
  }
}
