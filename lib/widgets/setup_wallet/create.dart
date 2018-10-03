/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';

class CreateWalletWidget extends StatefulWidget {
  final TextEditingController _nameController;
  final TextEditingController _aliasController;
  final bool _loading;
  CreateWalletWidget(
      this._nameController, this._aliasController, this._loading);

  @override
  _CreateWalletWidgetState createState() => _CreateWalletWidgetState();
}

class _CreateWalletWidgetState extends State<CreateWalletWidget> {
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
              controller: widget._nameController,
              decoration: InputDecoration(labelText: 'Name of your node'),
              validator: (value) {
                if (value.length < 3) {
                  return "Minimum 3 characters";
                }
              }),
          TextFormField(
            decoration: InputDecoration(
                labelText: 'Public alias of your node (optional)'),
            controller: widget._aliasController,
          ),
        ],
      ),
    );
  }
}
