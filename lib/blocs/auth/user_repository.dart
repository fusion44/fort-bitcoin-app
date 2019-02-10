/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:mobile_app/blocs/auth/register/register.dart';
import 'package:mobile_app/config.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/errors.dart';
import 'package:mobile_app/gql/mutations/user.dart';
import 'package:mobile_app/gql/queries/user.dart';
import 'package:mobile_app/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepositoryError extends Error {
  final String msg;
  UserRepositoryError(this.msg);
}

class RegistrationError extends Error {
  final RegisterFailureType type;
  final String msg;
  RegistrationError([this.type, this.msg]);

  @override
  String toString() => msg;
}

class BadCredentialsError extends Error {
  final String msg;
  BadCredentialsError([this.msg = "Bad credentials"]);

  @override
  String toString() => msg;
}

class UserRepository {
  final String _prefKeyAuthenticated = "authenticated";
  final String _prefKeyUserName = "auth_username";
  final String _prefKeyId = "auth_id";
  final String _prefKeyToken = "auth_token";

  static String _url = "$endPoint";
  static String _authApi = '$_url/api-token-auth/';
  static String _gql = '$_url/gql/';

  static UserRepository _instance;

  SharedPreferences _prefs;
  User _user;

  User get user => _user;

  static Future<UserRepository> getInstance() async {
    if (_instance == null) {
      _instance = UserRepository();
      await _instance._init();
    }
    return _instance;
  }

  Future _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _updateWalletStatus();
  }

  Future<String> authenticate({
    @required String username,
    @required String password,
    String email,
  }) async {
    _checkInit();

    String json = jsonEncode({"username": username, "password": password});
    var response;
    try {
      response = await http.post(_authApi,
          headers: {"Content-Type": "application/json"}, body: json);
    } on SocketException {
      throw NetworkError();
    }

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      await _loginUser(body);
      await _updateWalletStatus();
      return body["token"];
    } else {
      await _logoutUser();
      if (response.statusCode == 400) {
        throw BadCredentialsError();
      } else {
        throw UserRepositoryError("An unknown error occured: ${response.body}");
      }
    }
  }

  Future<bool> register({
    @required String username,
    @required String password,
    String email,
  }) async {
    _checkInit();

    String vars = jsonEncode(
        {"username": username, "password": password, "email": email});
    var json = jsonEncode({"query": createUser, "variables": vars});
    var response;
    try {
      response = await http.post(_gql,
          headers: {"Content-Type": "application/json"}, body: json);
    } on SocketException {
      throw NetworkError();
    }

    if (response.statusCode == 200) {
      var createUserData;
      String typename;
      try {
        createUserData =
            jsonDecode(response.body)["data"]["createUser"]["createUser"];
        typename = createUserData["__typename"];
      } catch (error) {
        throw UserRepositoryError(
            "Server returned unexpected data: ${response.body}");
      }

      switch (typename) {
        case "CreateUserSuccess":
          return true;
          break;
        case "CreateUserError":
          throw _handleRegisterError(createUserData);
          break;
        case "ServerError":
          throw UserRepositoryError(
              "Server error: ${createUserData["errorMessage"]}");
          break;
        default:
          throw UserRepositoryError(
              "An unknown error occured: ${response.body}");
      }
    } else {
      await _logoutUser();
      throw UserRepositoryError("An unknown error occured: ${response.body}");
    }
  }

  RegisterFailure _handleRegisterError(createUserData) {
    int errorType = createUserData["errorType"] ?? 0;
    String errorMessage =
        createUserData["errorMessage"] ?? "No error message given.";
    switch (errorType) {
      case 1: // USER_AUTHENTICATED = 1
        return RegisterFailure(
          type: RegisterFailureType.userAuthenticated,
          errorMessage: errorMessage,
        );
      case 2: // EMAIL_NOT_UNIQUE = 2
        return RegisterFailure(
          type: RegisterFailureType.emailNotUnique,
          errorMessage: errorMessage,
        );
      case 3: // USERNAME_NOT_UNIQUE = 3
        return RegisterFailure(
          type: RegisterFailureType.usernameNotUnique,
          errorMessage: errorMessage,
        );
      case 4: // USERNAME_TO_SHORT = 4
        return RegisterFailure(
          type: RegisterFailureType.usernameToShort,
          errorMessage: errorMessage,
        );
      case 5: // PASSWORD_TO_SHORT = 5
        return RegisterFailure(
          type: RegisterFailureType.passwordToShort,
          errorMessage: errorMessage,
        );
      default:
        return RegisterFailure(
          type: RegisterFailureType.unknown,
          errorMessage: errorMessage,
        );
    }
  }

  Future<void> logoutUser() async {
    _logoutUser();
  }

  bool isAuthenticated() => _user == null ? false : true;

  void _checkInit() {
    if (_prefs == null) {
      throw StateError("Use init() to initialize the UserRepository");
    }
  }

  Future _loginUser(body) async {
    int id = body["user"]['id'];
    String username = body["user"]['username'];
    String token = body["token"];

    _user = User(id, username, token, WalletState.unknown);
    _prefs.setBool(_prefKeyAuthenticated, true);
    _prefs.setInt(_prefKeyId, id);
    _prefs.setString(_prefKeyUserName, username);
    _prefs.setString(_prefKeyToken, token);
  }

  Future _logoutUser() async {
    _user = null;
    _prefs.setBool(_prefKeyAuthenticated, false);
    _prefs.setInt(_prefKeyId, -1);
    _prefs.setString(_prefKeyUserName, "");
    _prefs.setString(_prefKeyToken, "");
  }

  Future _updateWalletStatus() async {
    bool auth = _prefs.getBool(_prefKeyAuthenticated) ?? false;
    if (auth) {
      String authToken = _prefs.getString(_prefKeyToken);

      http.Response response = await http.post(_gql,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "JWT $authToken"
          },
          body: jsonEncode({"query": getUserInfo}));

      var json = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _handleGetCurrentUser(json, authToken);
        _handleWalletStatus(json);
      }
    }
  }

  bool _handleGetCurrentUser(json, String authToken) {
    var currentUserJSON = json["data"]["getCurrentUser"];
    switch (currentUserJSON["__typename"]) {
      case "Unauthenticated":
        // Token is not valid anymore
        print("Token invalid. Logging out");
        _logoutUser();
        break;
      case "ServerError":
      case "GetCurrentUserError":
        print("Error: ${currentUserJSON["errorMessage"]}");
        break;
      case "GetCurrentUserSuccess":
        // Token still valid
        int id = int.parse(currentUserJSON["user"]["id"]);
        String username = currentUserJSON["user"]["username"];
        _user = User(id, username, authToken, WalletState.unknown);
        break;
      default:
    }

    return _user != null ? true : false;
  }

  void _handleWalletStatus(json) {
    var walletData = json["data"]["getLnWalletStatus"];

    if (_user == null) {
      throw StateError("User cannot be null");
    }

    switch (walletData["__typename"]) {
      case "Unauthenticated":
        break;
      case "ServerError":
      case "GetLnWalletStatusError":
        print(walletData["errorMessage"]);
        _user.walletState = WalletState.unknown;
        break;
      case "WalletInstanceNotFound":
        // Wallet not found in the database
        _user.walletState = WalletState.notFound;
        break;
      case "GetLnWalletStatusNotInitialized":
        // Wallet found, but it is not initialized yet
        _user.walletState = WalletState.notInitialized;
        break;
      case "WalletInstanceNotRunning":
        _user.walletState = WalletState.notRunning;
        break;
      case "GetLnWalletStatusLocked":
        _user.walletState = WalletState.locked;
        break;
      case "GetLnWalletStatusOperational":
        _user.walletState = WalletState.ready;
        break;
      default:
    }
  }
}
