/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/authhelper.dart';
import 'package:mobile_app/blocs/config_bloc.dart';
import 'package:mobile_app/config.dart';
import 'package:mobile_app/pages/home.dart';
import 'package:mobile_app/pages/login.dart';
import 'package:mobile_app/pages/splash.dart';
import 'package:mobile_app/routes.dart';

void main() async {
  AuthHelper().init();
  ConfigurationBloc().init();

  runApp(FortBitcoinApp());
}

class FortBitcoinApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    StreamBuilder<AuthState> builder = StreamBuilder(
      initialData: AuthState.loggingIn,
      stream: AuthHelper().eventStream,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.hasError) {
          return new Center(child: Text("error"));
        }
        if (asyncSnapshot.hasData) {
          switch (asyncSnapshot.data) {
            case AuthState.loggingIn:
              return MaterialApp(
                title: 'Fort Bitcoin',
                theme: ThemeData.dark(),
                home: SplashPage(),
              );
            case AuthState.loggedIn:
              return _buildGraphQLProvider();
            case AuthState.loggedOut:
            case AuthState.loggingOut:
            case AuthState.loginError:
              return MaterialApp(
                title: "Fort Bitcoin",
                theme: ThemeData.dark(),
                home: LoginPage(),
              );
            default:
              return Center(child: Text("Implement me ${asyncSnapshot.data}"));
          }
        }
      },
    );

    return MaterialApp(title: 'Fort Bitcoin', home: builder);
  }
}

GraphQLProvider _buildGraphQLProvider() {
  HttpLink link = HttpLink(
    uri: '$endPoint/gql/',
    headers: <String, String>{
      'Authorization': 'JWT ${AuthHelper().user.token}',
    },
  );

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      cache: InMemoryCache(),
      link: link,
    ),
  );

  return GraphQLProvider(
    client: client,
    child: MaterialApp(
      title: 'Fort Bitcoin',
      theme: ThemeData.dark(),
      home: HomePage(),
      initialRoute: '/home',
      routes: routes,
    ),
  );
}
