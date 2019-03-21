/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/auth/auth/authentication.dart';
import 'package:mobile_app/auth/authentication_page.dart';
import 'package:mobile_app/auth/wallet/setup_wallet_page.dart';
import 'package:mobile_app/balance/channel_balance/channel_balance.dart';
import 'package:mobile_app/balance/invoice/invoice.dart';
import 'package:mobile_app/balance/onchain_data/onchain_data.dart';
import 'package:mobile_app/balance/payment/payment.dart';
import 'package:mobile_app/common/blocs/config_bloc.dart';
import 'package:mobile_app/common/pages/home_page.dart';
import 'package:mobile_app/common/pages/splash_page.dart';
import 'package:mobile_app/config.dart';
import 'package:mobile_app/connectivity/channels/channels_bloc.dart';
import 'package:mobile_app/connectivity/channels/open/open_channel.dart';
import 'package:mobile_app/connectivity/info/wallet_info.dart';
import 'package:mobile_app/connectivity/peer/peer.dart';
import 'package:mobile_app/models.dart';
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
                AuthenticationPage(),
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
              BlocProvider<WalletInfoBloc>(bloc: WalletInfoBloc(gqlCLient)),
              BlocProvider<OnchainDataBloc>(bloc: OnchainDataBloc(gqlCLient)),
              BlocProvider<ListPaymentBloc>(bloc: ListPaymentBloc(gqlCLient)),
              BlocProvider<ListInvoiceBloc>(bloc: ListInvoiceBloc(gqlCLient)),
              BlocProvider<ChannelBalanceBloc>(
                  bloc: ChannelBalanceBloc(gqlCLient)),
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
