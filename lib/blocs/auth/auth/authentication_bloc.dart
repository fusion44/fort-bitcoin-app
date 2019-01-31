/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mobile_app/blocs/auth/auth/authentication_event.dart';
import 'package:mobile_app/blocs/auth/auth/authentication_state.dart';
import 'package:mobile_app/blocs/auth/user_repository.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  UserRepository _userRepository;
  UserRepository get userRepository => _userRepository;

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationState currentState,
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      _userRepository = await UserRepository.getInstance();
      final bool isAuthenticated = userRepository.isAuthenticated();

      if (isAuthenticated) {
        yield AuthenticationAuthenticated(user: userRepository.user);
      } else {
        yield AuthenticationUnauthenticated();
      }
    }

    if (event is LoggedIn) {
      yield AuthenticationAuthenticated(user: userRepository.user);
    }

    if (event is LoggedOut) {
      yield AuthenticationUnauthenticated();
    }
  }
}
