/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:mobile_app/models.dart';

abstract class AuthenticationState extends Equatable {}

class AuthenticationUninitialized extends AuthenticationState {
  @override
  String toString() => "AuthenticationUninitialized";
}

class AuthenticationAuthenticated extends AuthenticationState {
  final User user;

  AuthenticationAuthenticated({@required this.user});

  @override
  String toString() => "AuthenticationAuthenticated";
}

class AuthenticationUnauthenticated extends AuthenticationState {
  @override
  String toString() => "AuthenticationUnauthenticated";
}

class AuthenticationLoading extends AuthenticationState {
  @override
  String toString() => "AuthenticationLoading";
}
