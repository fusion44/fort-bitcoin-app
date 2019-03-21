/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/common/widgets/card_base.dart';
import 'package:mobile_app/models.dart';

/// Displays an error icon and the error text
/// or texts in the theme's error colors
class ErrorDisplayCard extends StatelessWidget {
  final String _header;
  final Iterable<DataFetchError> _errors;

  ErrorDisplayCard(this._header, this._errors);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    List<Widget> children = [];
    children.add(
      Icon(
        Icons.error,
        size: 75.0,
        color: theme.errorColor,
      ),
    );
    for (DataFetchError err in _errors) {
      children.add(
        Text(
          err.message,
          style: TextStyle(color: theme.errorColor, fontSize: 25.0),
        ),
      );
    }
    return CardBase(_header, Column(children: children));
  }
}
