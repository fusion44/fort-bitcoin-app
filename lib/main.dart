/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/authhelper.dart';
import 'package:mobile_app/blocs/channels_bloc.dart';
import 'package:mobile_app/blocs/config_bloc.dart';
import 'package:mobile_app/blocs/node_info_bloc.dart';
import 'package:mobile_app/blocs/open_channel/open_channel_bloc.dart';
import 'package:mobile_app/blocs/peers_bloc.dart';
import 'package:mobile_app/config.dart';
import 'package:mobile_app/pages/home.dart';
import 'package:mobile_app/pages/setup_wallet.dart';
import 'package:mobile_app/pages/signup.dart';
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
    StreamBuilder<AuthData> builder = StreamBuilder(
      initialData: AuthData.initial(),
      stream: AuthHelper().eventStream,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.hasError) {
          return new Center(child: Text("error"));
        }
        if (asyncSnapshot.hasData) {
          switch (asyncSnapshot.data.state) {
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
                home:
                    SignupPage(errorMessage: asyncSnapshot.data.message ?? ""),
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
  GraphQLClient gqlCLient = GraphQLClient(
    cache: InMemoryCache(),
    link: link,
  );

  Widget page;
  String route;
  if (AuthHelper().user.walletIsInitialized) {
    page = HomePage();
    route = "/home";
  } else {
    page = SetupWalletPage();
    route = "/setup_wallet";
  }

  return GraphQLProvider(
    client: ValueNotifier(gqlCLient),
    child: MaterialApp(
      builder: (BuildContext context, Widget child) {
        var channelBloc = ChannelBloc(gqlCLient);
        var openChannelBloc = OpenChannelBloc();
        var peersBloc = PeerBloc(gqlCLient);
        var nodeInfoBloc = NodeInfoBloc(gqlCLient);

        return BlocProvider<ChannelBloc>(
          bloc: channelBloc,
          child: BlocProvider<OpenChannelBloc>(
            bloc: openChannelBloc,
            child: BlocProvider<PeerBloc>(
              bloc: peersBloc,
              child:
                  BlocProvider<NodeInfoBloc>(bloc: nodeInfoBloc, child: child),
            ),
          ),
        );
      },
      title: 'Fort Bitcoin',
      theme: ThemeData.dark(),
      home: page,
      initialRoute: route,
      routes: routes,
    ),
  );
}
