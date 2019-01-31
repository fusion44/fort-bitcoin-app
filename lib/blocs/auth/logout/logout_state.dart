/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class LogoutState extends Equatable {
  LogoutState([List props = const []]) : super(props);
}

class LogoutFailure extends LogoutState {
  final String error;

  LogoutFailure({@required this.error}) : super([error]);

  @override
  String toString() => "LogoutFailure { error: $error }";
}
