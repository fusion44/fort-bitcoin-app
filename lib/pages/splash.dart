/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/authhelper.dart';

class SplashPage extends StatefulWidget {
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  StreamSubscription<dynamic> _sub;
  Client _client;

  @override
  void initState() {
    _sub = AuthHelper().eventStream.listen((authState) {
      if (authState == AuthState.loggedIn) {
        _client.apiToken = AuthHelper().user.token;
        Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
      } else if (authState == AuthState.loggedOut) {
        _client.apiToken = "";
        Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
      }
      // Else: Display the splash screen as the
      // AuthHelper still determines if the user is
      // correctly logged in or not
    });
    AuthHelper().init();
    super.initState();
  }

  @override
  void dispose() {
    _client = null;
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _client = GraphqlProvider.of(context).value;
    ThemeData theme = Theme.of(context);
    return Container(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          "Fort Bitcoin",
          style: theme.textTheme.display2,
        ),
        Text(
          "is loading...",
          style: theme.textTheme.subhead,
        )
      ]),
    );
  }
}
