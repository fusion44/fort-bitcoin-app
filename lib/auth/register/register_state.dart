/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class RegisterState extends Equatable {
  RegisterState([List props = const []]) : super(props);
}

class RegisterInitial extends RegisterState {
  @override
  String toString() => "RegisterInitial";
}

class RegisterLoading extends RegisterState {
  @override
  String toString() => "RegisterLoading";
}

class RegisteredNowAuthenticating extends RegisterState {
  @override
  String toString() => "RegisteredNowAuthenticating";
}

enum RegisterFailureType {
  userAuthenticated,
  emailNotUnique,
  usernameNotUnique,
  usernameToShort,
  passwordToShort,
  networkError,
  unknown
}

class RegisterFailure extends RegisterState {
  final RegisterFailureType type;
  final String errorMessage;

  RegisterFailure({@required this.type, @required this.errorMessage})
      : super([type, errorMessage]);

  @override
  String toString() => "RegisterFailure { error: $errorMessage }";
}
