/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import "package:flutter/material.dart";

class InitWalletWidget extends StatefulWidget {
  final TextEditingController _recoveryWindowController;
  final TextEditingController _walletPasswordController;
  final bool _loading;
  InitWalletWidget(this._recoveryWindowController,
      this._walletPasswordController, this._loading);

  @override
  _InitWalletWidgetState createState() => _InitWalletWidgetState();
}

class _InitWalletWidgetState extends State<InitWalletWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          widget._loading == true ? LinearProgressIndicator() : Container(),
          TextFormField(
            autofocus: true,
            decoration: InputDecoration(labelText: "Wallet password"),
            controller: widget._walletPasswordController,
            obscureText: true,
          ),
          TextFormField(
              controller: widget._recoveryWindowController,
              keyboardType: TextInputType.numberWithOptions(
                  signed: false, decimal: false),
              decoration: InputDecoration(
                  labelText: "Recovery window for the node (optional)"),
              validator: (value) {
                if (value.length < 3) {
                  return "Minimum 3 characters";
                }
              }),
        ],
      ),
    );
  }
}
