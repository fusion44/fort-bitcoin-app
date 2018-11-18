/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';

class HelpFormTextField extends StatefulWidget {
  final String helpText;
  final TextEditingController controller;
  final InputDecoration decoration;
  final TextInputType keyboardType;
  final Function validator;

  const HelpFormTextField(
      {Key key,
      this.helpText,
      this.controller,
      this.decoration,
      this.keyboardType,
      this.validator})
      : super(key: key);

  _HelpFormTextFieldState createState() => _HelpFormTextFieldState();
}

class _HelpFormTextFieldState extends State<HelpFormTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        alignment: AlignmentDirectional.centerEnd,
        children: <Widget>[
          TextFormField(
            keyboardType: widget.keyboardType,
            decoration: widget.decoration,
            controller: widget.controller,
            validator: widget.validator,
          ),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => _showHelpText(),
          )
        ],
      ),
    );
  }

  _showHelpText() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(widget.helpText)));
    });
  }
}
