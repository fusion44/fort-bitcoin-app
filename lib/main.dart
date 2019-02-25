/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/blocs/auth/auth/authentication.dart';
import 'package:mobile_app/blocs/channels_bloc.dart';
import 'package:mobile_app/blocs/config_bloc.dart';
import 'package:mobile_app/blocs/node_info_bloc.dart';
import 'package:mobile_app/blocs/open_channel/open_channel_bloc.dart';
import 'package:mobile_app/blocs/peers_bloc.dart';
import 'package:mobile_app/blocs/wallet_info/wallet_info.dart';
import 'package:mobile_app/config.dart';
import 'package:mobile_app/models.dart';
import 'package:mobile_app/pages/home.dart';
import 'package:mobile_app/pages/setup_wallet.dart';
import 'package:mobile_app/pages/signup.dart';
import 'package:mobile_app/pages/splash.dart';
import 'package:mobile_app/routes.dart';

void main() async {
  ConfigurationBloc().init();
  runApp(FortBitcoinApp());
}

class FortBitcoinApp extends StatefulWidget {
  @override
  FortBitcoinAppState createState() {
    return FortBitcoinAppState();
  }
}

class FortBitcoinAppState extends State<FortBitcoinApp> {
  AuthenticationBloc _authBloc;

  @override
  void initState() {
    _authBloc = AuthenticationBloc();
    _authBloc.dispatch(AppStarted());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
      bloc: _authBloc,
      child: MaterialApp(
        home: BlocBuilder<AuthenticationEvent, AuthenticationState>(
          bloc: _authBloc,
          builder: (BuildContext context, AuthenticationState state) {
            if (state is AuthenticationUninitialized ||
                state is AuthenticationLoading) {
              return _buildMaterialApp(SplashPage());
            }

            if (state is AuthenticationUnauthenticated) {
              return _buildMaterialApp(
                SignupPage(),
              );
            }

            if (state is AuthenticationAuthenticated) {
              return _buildGraphQLProvider(state.user.walletState);
            }

            return Center(child: Text("Implement me $state"));
          },
        ),
      ),
    );
  }

  GraphQLProvider _buildGraphQLProvider(WalletState walletState) {
    String token = _authBloc.userRepository.user.token;
    HttpLink link = HttpLink(
      uri: '$endPoint/gql/',
      headers: <String, String>{
        "Authorization": "JWT $token",
      },
    );
    GraphQLClient gqlCLient = GraphQLClient(
      cache: InMemoryCache(),
      link: link,
    );

    Widget page;
    String route;
    if (walletState == WalletState.notFound ||
        walletState == WalletState.notInitialized) {
      page = SetupWalletPage();
      route = "/setup_wallet";
    } else {
      page = HomePage();
      route = "/home";
    }

    return GraphQLProvider(
      client: ValueNotifier(gqlCLient),
      child: MaterialApp(
        builder: (BuildContext context, Widget child) {
          return BlocProviderTree(
            blocProviders: [
              BlocProvider<ChannelBloc>(bloc: ChannelBloc(gqlCLient)),
              BlocProvider<OpenChannelBloc>(bloc: OpenChannelBloc(token)),
              BlocProvider<PeerBloc>(bloc: PeerBloc(gqlCLient)),
              BlocProvider<NodeInfoBloc>(bloc: NodeInfoBloc(gqlCLient)),
              BlocProvider<WalletInfoBloc>(bloc: WalletInfoBloc(gqlCLient)),
            ],
            child: child,
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
}

MaterialApp _buildMaterialApp(Widget home) {
  return MaterialApp(
    title: "Fort Bitcoin",
    theme: ThemeData.dark(),
    home: home,
  );
}
