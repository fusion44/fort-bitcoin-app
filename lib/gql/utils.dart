/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:convert';

import 'package:mobile_app/models.dart';

// Checks if a graphql response contains errors and
// returns a Map with all errors excapsulated
// into DataFetchError objects
Map<String, DataFetchError> processGraphqlErrors(response) {
  Map<String, DataFetchError> errors = Map();

  if (response.containsKey("errors")) {
    for (var error in response["errors"]) {
      int code;
      String message;
      jsonDecode(error["message"], reviver: (k, v) {
        if (k == "code") {
          code = v;
        } else if (k == "message") {
          message = v;
        }
      });
      DataFetchError err = DataFetchError(code, message, error["path"][0]);
      errors[err.path] = err;
    }
  }

  return errors;
}
