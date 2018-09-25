/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:async';
import 'dart:convert';
import 'package:mobile_app/config.dart';
import 'package:http/http.dart' as http;

class Configuration {
  bool testnet;
  Configuration(this.testnet);
}

/*
Singleton class that fetches the server configuration as soon
as possible at startup. We query the GraphQL API here with 
a http POST call because when this is called flutter-graphql 
hasn't yet been started.
*/
class ConfigurationBloc {
  static String _url = "$endPoint";
  static String _gql = '$_url/gql/';

  StreamController<Configuration> _streamController =
      StreamController.broadcast();
  Stream<Configuration> get eventStream => _streamController.stream;

  Configuration _configuration;
  Configuration get config => _configuration;

  bool _isInitialized = false;
  bool get initialized => _isInitialized;

  Future<Configuration> init() async {
    if (_isInitialized) {
      return _configuration;
    }
    var json = jsonEncode({"query": "{ getConfiguration { testnet } }"});

    http.Response response = await http.post(_gql,
        headers: {"Content-Type": "application/json"}, body: json);

    if (response.statusCode == 200) {
      _successfulFetch(response);
    } else {
      print("Error while fetching configuration");
    }

    _isInitialized = true;
    return _configuration;
  }

  void dispose() {
    _streamController.close();
  }

  Future _successfulFetch(http.Response response) async {
    var body = jsonDecode(response.body);
    bool testnet = body["data"]["getConfiguration"]["testnet"];
    _setState(Configuration(testnet));
  }

  void _setState(Configuration newState) {
    _configuration = newState;
    _streamController.add(_configuration);
  }

  // Singleton stuff
  static final ConfigurationBloc _singleton = ConfigurationBloc._internal();
  factory ConfigurationBloc() {
    return _singleton;
  }
  ConfigurationBloc._internal();
}
