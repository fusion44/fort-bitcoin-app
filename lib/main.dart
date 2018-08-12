/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/config.dart';
import 'package:mobile_app/pages/splash.dart';
import 'package:mobile_app/routes.dart';

void main() {
  ValueNotifier<Client> client = ValueNotifier(
    Client(
      endPoint: '$endPoint/gql/',
      cache: InMemoryCache(),
    ),
  );

  runApp(FortBitcoinApp(client));
}

class FortBitcoinApp extends StatelessWidget {
  final ValueNotifier<Client> _client;

  FortBitcoinApp([this._client]);

  @override
  Widget build(BuildContext context) {
    return GraphqlProvider(
      client: _client,
      child: MaterialApp(
        title: 'Fort Bitcoin',
        theme: ThemeData.dark(),
        home: SplashPage(),
        initialRoute: '/splash',
        routes: routes,
      ),
    );
  }
}
