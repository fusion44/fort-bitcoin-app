/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/authhelper.dart';

class RegisterWidget extends StatefulWidget {
  @override
  _RegisterWidgetState createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordController2 = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      body: SingleChildScrollView(
        child: Form(
          autovalidate: true,
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                    autofocus: true,
                    controller: _usernameController,
                    decoration:
                        InputDecoration(labelText: 'Enter your username'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Minimum 3 characters";
                      }
                    }),
                TextFormField(
                    decoration:
                        InputDecoration(labelText: 'Enter your password'),
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value.length < 8) {
                        return "Minimum 8 characters";
                      }
                      if (value != _passwordController2.value.text) {
                        return "Passwords don't match";
                      }
                    }),
                TextFormField(
                    decoration:
                        InputDecoration(labelText: 'Verify your password'),
                    controller: _passwordController2,
                    obscureText: true,
                    validator: (value) {
                      if (value.length < 8) {
                        return "Minimum 8 characters";
                      }
                      if (value != _passwordController.value.text) {
                        return "Passwords don't match";
                      }
                    }),
                TextFormField(
                    decoration:
                        InputDecoration(labelText: 'Email address (optional)'),
                    controller: _emailController,
                    validator: (value) {
                      if (value != "" && !value.contains("@")) {
                        return "Must be an email address";
                      }
                      if (value.length < 5) {
                        return "Email address is to short";
                      }
                    }),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: RaisedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        AuthHelper()
                            .register(
                                _usernameController.value.text,
                                _passwordController.value.text,
                                _emailController.value.text)
                            .then((authState) {
                          if (authState == AuthState.loggedIn) {
                            Navigator.pushNamedAndRemoveUntil(
                                context, "/home", (_) => false);
                          }
                        });
                      }
                    },
                    child: Text("Register"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
