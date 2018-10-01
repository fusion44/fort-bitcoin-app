/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

// Represents a user data object.
class User {
  int _userid;
  int get id => _userid;

  String _username;
  String get name => _username;

  String token;

  bool _walletIsInitialized;
  bool get walletIsInitialized => _walletIsInitialized;

  User(this._userid, this._username, this.token, this._walletIsInitialized);

  static User empty() {
    return User(0, "", "", false);
  }
}

/// Represents an error when a query returned with an error
/// Server returns error codes >= 0
/// negative error values can be used when the cause is
/// local (API not reachable etc)
class DataFetchError {
  final int code;
  final String message;
  final String path;

  DataFetchError(this.code, this.message, this.path);
}
