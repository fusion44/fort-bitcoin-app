/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:mobile_app/auth/auth/authentication.dart';
import 'package:mobile_app/auth/login/login_event.dart';
import 'package:mobile_app/auth/login/login_state.dart';
import 'package:mobile_app/errors.dart';
import 'package:mobile_app/auth/user_repository.dart';

class LoginBloc extends Bloc<LoginStateEvent, LoginState> {
  final AuthenticationBloc authBloc;

  LoginBloc({
    @required this.authBloc,
  }) : assert(authBloc != null);

  @override
  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(
    LoginState currentState,
    LoginStateEvent event,
  ) async* {
    if (event is LoginButtonPressed) {
      yield LoginLoading();

      try {
        final token = await authBloc.userRepository.authenticate(
          username: event.username,
          password: event.password,
        );

        authBloc.dispatch(LoggedIn(token: token));
        yield LoginInitial();
      } on BadCredentialsError catch (badCredError) {
        yield LoginFailure(
            type: LoginFailureType.badCredentials,
            errorMessage: badCredError.toString());
      } on NetworkError catch (networkError) {
        yield LoginFailure(
            type: LoginFailureType.networkError,
            errorMessage: networkError.msg);
      } on UserRepositoryError catch (userRepoError) {
        yield LoginFailure(
            type: LoginFailureType.unknown, errorMessage: userRepoError.msg);
      }
    }
  }
}
