/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:mobile_app/auth/auth/authentication.dart';
import 'package:mobile_app/auth/register/register_event.dart';
import 'package:mobile_app/auth/register/register_state.dart';
import 'package:mobile_app/errors.dart';
import 'package:mobile_app/auth/user_repository.dart';

class RegisterBloc extends Bloc<RegisterStateEvent, RegisterState> {
  final AuthenticationBloc authBloc;

  RegisterBloc({
    @required this.authBloc,
  }) : assert(authBloc != null);

  @override
  RegisterState get initialState => RegisterInitial();

  @override
  Stream<RegisterState> mapEventToState(
    RegisterState currentState,
    RegisterStateEvent event,
  ) async* {
    if (event is RegisterButtonPressed) {
      yield RegisterLoading();

      try {
        await authBloc.userRepository.register(
          username: event.username,
          password: event.password,
          email: event.email,
        );
      } on RegisterFailure catch (registerFailure) {
        yield registerFailure;
        return;
      } on NetworkError catch (networkError) {
        yield RegisterFailure(
          type: RegisterFailureType.networkError,
          errorMessage: networkError.msg,
        );
        return;
      } on UserRepositoryError catch (userRepoError) {
        yield RegisterFailure(
          type: RegisterFailureType.unknown,
          errorMessage: userRepoError.msg,
        );
        return;
      }

      try {
        yield RegisteredNowAuthenticating();
        String token = await authBloc.userRepository.authenticate(
          username: event.username,
          password: event.password,
        );
        authBloc.dispatch(LoggedIn(token: token));
      } on BadCredentialsError catch (badCredError) {
        yield RegisterFailure(
          type: RegisterFailureType.unknown,
          errorMessage: badCredError.msg,
        );
      } on NetworkError catch (networkError) {
        yield RegisterFailure(
          type: RegisterFailureType.networkError,
          errorMessage: networkError.msg,
        );
      } on UserRepositoryError catch (userRepoError) {
        yield RegisterFailure(
          type: RegisterFailureType.unknown,
          errorMessage: userRepoError.msg,
        );
      }
    }
  }
}
