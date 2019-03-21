/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:mobile_app/auth/auth/authentication.dart';
import 'package:mobile_app/auth/logout/logout_event.dart';
import 'package:mobile_app/auth/logout/logout_state.dart';

class LogoutBloc extends Bloc<LogoutStateEvent, LogoutState> {
  final AuthenticationBloc authBloc;

  LogoutBloc({
    @required this.authBloc,
  }) : assert(authBloc != null);

  @override
  Stream<LogoutState> mapEventToState(
    LogoutState currentState,
    LogoutStateEvent event,
  ) async* {
    if (event is LogoutButtonPressed) {
      try {
        await authBloc.userRepository.logoutUser();
        authBloc.dispatch(LoggedOut());
      } catch (error) {
        yield LogoutFailure(error: error.toString());
      }
    }
  }

  @override
  LogoutState get initialState => null;
}
