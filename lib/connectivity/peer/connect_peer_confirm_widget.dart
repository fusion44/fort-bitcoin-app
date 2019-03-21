/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';

class ConnectPeerConfirmWidget extends StatefulWidget {
  final String _nodeId;
  final String _nodeHost;
  final Function _onConnectClick;
  final Function _onCancelClick;
  final Function _onPermanentToggled;

  const ConnectPeerConfirmWidget(this._nodeId, this._nodeHost,
      this._onConnectClick, this._onCancelClick, this._onPermanentToggled);

  _ConnectPeerConfirmWidgetState createState() =>
      _ConnectPeerConfirmWidgetState();
}

class _ConnectPeerConfirmWidgetState extends State<ConnectPeerConfirmWidget> {
  bool _keepAlive = false;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Center(
              child: Text(
                "Connection Info",
                style: theme.textTheme.display1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Center(
                child: Text(
                  "Node ID:",
                  style: theme.textTheme.headline,
                ),
              ),
            ),
            Center(
              child: Text(
                widget._nodeId,
                style: theme.textTheme.body1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Center(
                child: Text(
                  "Node Host:",
                  style: theme.textTheme.headline,
                ),
              ),
            ),
            Center(
              child: Text(
                widget._nodeHost,
                style: theme.textTheme.body1,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Keep alive"),
                Switch(
                    value: _keepAlive,
                    onChanged: (bool state) {
                      widget._onPermanentToggled(state);
                      setState(() {
                        _keepAlive = state;
                      });
                    }),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                      child: Text("Connect"),
                      onPressed: widget._onConnectClick),
                  Container(
                    width: 25.0,
                  ),
                  RaisedButton(
                    color: theme.secondaryHeaderColor,
                    child: Text("Cancel"),
                    onPressed: widget._onCancelClick,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
