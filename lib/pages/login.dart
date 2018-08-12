/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/authhelper.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Fort Bitcoin",
                style: theme.textTheme.display3,
              ),
              Text("Login", style: theme.textTheme.headline),
              TextFormField(
                  autofocus: true,
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Enter your username'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Minimum 3 characters";
                    }
                  }),
              TextFormField(
                  decoration: InputDecoration(labelText: 'Enter your password'),
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Minimum 8 characters";
                    }
                  }),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      AuthHelper()
                          .login(_usernameController.value.text,
                              _passwordController.value.text)
                          .then((authState) {
                        if (authState == AuthState.loggedIn) {
                          Client client = GraphqlProvider.of(context).value;
                          client.apiToken = AuthHelper().user.token;
                          Navigator.pushNamedAndRemoveUntil(
                              context, "/home", (_) => false);
                        }
                      });
                    }
                  },
                  child: Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
