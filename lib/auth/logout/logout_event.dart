/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:equatable/equatable.dart';

abstract class LogoutStateEvent extends Equatable {
  LogoutStateEvent([List props = const []]) : super(props);
}

class LogoutButtonPressed extends LogoutStateEvent {
  @override
  String toString() => "LogoutButtonPressed";
}
