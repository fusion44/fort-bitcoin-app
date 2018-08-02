/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';

class CardBase extends StatelessWidget {
  final bool _loading;
  final String _header;
  final Widget _content;

  CardBase(
    this._header,
    this._content, [
    this._loading = false,
  ]);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Card(
        elevation: 2.0,
        margin: EdgeInsets.all(10.0),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(bottom: 5.0),
                      child: Text(
                        _header,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headline,
                      ))
                ],
              ),
              _loading ? LinearProgressIndicator() : Container(),
              _content,
            ],
          ),
        ));
  }
}
