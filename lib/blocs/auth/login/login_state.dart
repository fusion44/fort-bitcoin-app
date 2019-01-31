/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  LoginState([List props = const []]) : super(props);
}

class LoginInitial extends LoginState {
  @override
  String toString() => "LoginInitial";
}

class LoginLoading extends LoginState {
  @override
  String toString() => "LoginLoading";
}

enum LoginFailureType {
  unknown,
  badCredentials,
  networkError,
}

class LoginFailure extends LoginState {
  final LoginFailureType type;
  final String errorMessage;

  LoginFailure({@required this.type, @required this.errorMessage})
      : super([type, errorMessage]);

  @override
  String toString() => "LoginFailure { error: $errorMessage }";
}
