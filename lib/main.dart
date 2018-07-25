/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/pages/home.dart';

void main() {
  client = new Client(
    endPoint: 'https://4e5dce1f.ngrok.io/gql/',
    cache: new InMemoryCache(),
  );
  client.apiToken = '';

  runApp(new FortBitcoinApp());
}

class FortBitcoinApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CacheProvider(
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
