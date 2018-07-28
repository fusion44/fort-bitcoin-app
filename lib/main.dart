/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/pages/home.dart';

void main() {
  ValueNotifier<Client> client = ValueNotifier(
    Client(
      endPoint: 'https://4e5dce1f.ngrok.io/gql/',
      cache: InMemoryCache(),
    ),
  );

  runApp(new FortBitcoinApp(client));
}

class FortBitcoinApp extends StatelessWidget {
  ValueNotifier<Client> _client;

  FortBitcoinApp([this._client]);

  @override
  Widget build(BuildContext context) {
    return GraphqlProvider(
      client: _client,
      child: MaterialApp(
        title: 'Fort Bitcoin',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      ),
    );
  }
}
