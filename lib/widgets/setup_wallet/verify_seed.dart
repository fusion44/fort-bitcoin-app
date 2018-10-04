/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import "package:flutter/material.dart";

class VerifySeedWidget extends StatefulWidget {
  final int word1Pos;
  final String word1;
  final int word2Pos;
  final String word2;
  final Function matchCallback;

  VerifySeedWidget(
      this.word1Pos, this.word1, this.word2Pos, this.word2, this.matchCallback);

  @override
  _VerifySeedWidgetState createState() => _VerifySeedWidgetState();
}

class _VerifySeedWidgetState extends State<VerifySeedWidget> {
  final _formKey = GlobalKey<FormState>();
  final _word1Controller = TextEditingController();
  final _word2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: true,
      onChanged: () {
        if (_word1Controller.value.text == widget.word1 &&
            _word2Controller.value.text == widget.word2) {
          widget.matchCallback(true);
        } else {
          widget.matchCallback(false);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextFormField(
              controller: _word1Controller,
              decoration: InputDecoration(
                  labelText:
                      "Enter word ${widget.word1Pos + 1} ${widget.word1}"),
              validator: (value) {
                if (value != widget.word1) {
                  return "Word one doesn't match";
                }
              }),
          TextFormField(
              decoration: InputDecoration(
                  labelText:
                      "Enter word ${widget.word2Pos + 1} ${widget.word2}"),
              controller: _word2Controller,
              validator: (value) {
                if (value != widget.word2) {
                  return "Word two doesn't match";
                }
              }),
        ],
      ),
    );
  }
}
