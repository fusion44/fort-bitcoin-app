/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/login.dart';
import 'package:mobile_app/widgets/register.dart';

class SignupPage extends StatefulWidget {
  final String errorMessage;

  const SignupPage({Key key, this.errorMessage = ""}) : super(key: key);
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    if (widget.errorMessage.isNotEmpty) {
      _showErrorMessageDialog(widget.errorMessage);
    }

    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            bottom: TabBar(
              tabs: [
                Tab(text: "Login"),
                Tab(text: "Register"),
              ],
            ),
            title: Text(
              "Fort Bitcoin",
              style: theme.textTheme.display3,
            ),
          ),
          body: TabBarView(
            children: [
              LoginWidget(),
              RegisterWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Future<Null> _showErrorMessageDialog(String message) async {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await showDialog<Null>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: SingleChildScrollView(
                child: Text(message),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
