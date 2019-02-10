/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/auth/register/register.dart';

class RegisterWidget extends StatefulWidget {
  final RegisterBloc registerBloc;

  const RegisterWidget({Key key, this.registerBloc}) : super(key: key);

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
    return BlocBuilder<RegisterStateEvent, RegisterState>(
      bloc: widget.registerBloc,
      builder: (BuildContext context, RegisterState state) {
        String emailError;
        String usernameError;
        String passwordError;
        if (state is RegisterFailure) {
          switch (state.type) {
            case RegisterFailureType.emailNotUnique:
              emailError = state.errorMessage;
              break;
            case RegisterFailureType.usernameNotUnique:
            case RegisterFailureType.usernameToShort:
              usernameError = state.errorMessage;
              break;
            case RegisterFailureType.passwordToShort:
              passwordError = state.errorMessage;
              break;
            case RegisterFailureType.networkError:
              _showSnackbar(context, state.errorMessage);
              break;
            default:
              _showSnackbar(context, state.errorMessage);
          }
        }

        return Scaffold(
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
                        decoration: InputDecoration(
                          labelText: 'Enter your username',
                          errorText: usernameError,
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Minimum 3 characters";
                          }
                        }),
                    TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Enter your password',
                          errorText: passwordError,
                        ),
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
                        decoration: InputDecoration(
                          labelText: 'Verify your password',
                          errorText: passwordError,
                        ),
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
                        decoration: InputDecoration(
                          labelText: 'Email address (optional)',
                          errorText: emailError,
                        ),
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
                      child: _buildRaisedButton(state),
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

  RaisedButton _buildRaisedButton(RegisterState state) {
    if (state is RegisterLoading) {
      return RaisedButton(
        onPressed: null,
        child: Text("Registering ..."),
      );
    } else if (state is RegisteredNowAuthenticating) {
      return RaisedButton(
        onPressed: null,
        child: Text("Authenticating ..."),
      );
    } else {
      return RaisedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            widget.registerBloc.dispatch(
              RegisterButtonPressed(
                username: _usernameController.value.text,
                password: _passwordController.value.text,
                email: _emailController.value.text,
              ),
            );
          }
        },
        child: Text("Register"),
      );
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
      },
    );
  }
}
