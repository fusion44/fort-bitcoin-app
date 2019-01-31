/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class LoginStateEvent extends Equatable {
  LoginStateEvent([List props = const []]) : super(props);
}

class LoginButtonPressed extends LoginStateEvent {
  final String username;
  final String password;

  LoginButtonPressed({
    @required this.username,
    @required this.password,
  }) : super([username, password]);

  @override
  String toString() => "LoginButtonPressed { username: $username }";
}
