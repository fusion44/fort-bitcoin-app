/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/auth/login/login.dart';

class LoginWidget extends StatefulWidget {
  final LoginBloc loginBloc;

  const LoginWidget({Key key, @required this.loginBloc}) : super(key: key);

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String credentialErrorMessage;
    return BlocBuilder<LoginStateEvent, LoginState>(
      bloc: widget.loginBloc,
      builder: (BuildContext context, LoginState state) {
        RaisedButton button;
        if (state is LoginLoading) {
          button = RaisedButton(
            onPressed: null,
            child: Text("Working ..."),
          );
        } else if (state is LoginFailure) {
          if (state.type == LoginFailureType.badCredentials) {
            credentialErrorMessage = state.errorMessage;
          }
          if (state.type == LoginFailureType.networkError) {
            _showErrorMessageDialog(state.errorMessage);
          }
          button = _standardButton();
        } else {
          // LoginInitial && LoginError
          button = _standardButton();
        }

        return Scaffold(
          resizeToAvoidBottomPadding: false,
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                        autofocus: true,
                        controller: _usernameController,
                        decoration: InputDecoration(
                            labelText: 'Enter your username',
                            errorText: credentialErrorMessage),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Minimum 3 characters";
                          }
                        }),
                    TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Enter your password',
                            errorText: credentialErrorMessage),
                        controller: _passwordController,
                        obscureText: true,
                        validator: (value) {
                          if (value.length < 8) {
                            return "Minimum 8 characters";
                          }
                        }),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: button,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  RaisedButton _standardButton() {
    return RaisedButton(
      onPressed: () {
        if (_formKey.currentState.validate()) {
          widget.loginBloc.dispatch(LoginButtonPressed(
              username: _usernameController.value.text,
              password: _passwordController.value.text));
        }
      },
      child: Text("Login"),
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
              title: Text('Ooops ...'),
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
