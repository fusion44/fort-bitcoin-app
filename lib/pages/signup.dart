/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/auth/auth/authentication.dart';
import 'package:mobile_app/blocs/auth/login/login.dart';
import 'package:mobile_app/blocs/auth/register/register.dart';
import 'package:mobile_app/widgets/login.dart';
import 'package:mobile_app/widgets/register.dart';

class SignupPage extends StatefulWidget {
  final String errorMessage;

  const SignupPage({Key key, this.errorMessage = ""}) : super(key: key);
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  AuthenticationBloc _authenticationBloc;
  LoginBloc _loginBloc;
  RegisterBloc _registerBloc;

  @override
  void initState() {
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _loginBloc = LoginBloc(authBloc: _authenticationBloc);
    _registerBloc = RegisterBloc(authBloc: _authenticationBloc);
    super.initState();
  }

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
              LoginWidget(loginBloc: _loginBloc),
              RegisterWidget(registerBloc: _registerBloc),
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
