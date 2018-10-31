/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/blocs/channels_bloc.dart';
import 'package:mobile_app/blocs/config_bloc.dart';
import 'package:mobile_app/blocs/node_info_bloc.dart';
import 'package:mobile_app/blocs/peers_bloc.dart';
import 'package:mobile_app/pages/channels.dart';
import 'package:mobile_app/pages/node_info.dart';
import 'package:mobile_app/pages/peers.dart';
import 'package:mobile_app/routes.dart';

class ConnectivityPage extends StatefulWidget {
  static IconData icon = Icons.network_locked;
  static String appBarText = "Connectivity";

  @override
  _ConnectivityPageState createState() => _ConnectivityPageState();
}

class _ConnectivityPageState extends State<ConnectivityPage> {
  PeerBloc _peersBloc;
  ChannelBloc _channelBloc;
  NodeInfoBloc _nodeInfoBloc;

  int _bottomNavbarIndex = 0;
  BottomNavbarPagesConn _page = BottomNavbarPagesConn.channels;
  List<BottomNavigationBarItem> navItems = [
    BottomNavigationBarItem(
        title: const Text("Channels"), icon: const Icon(Icons.show_chart)),
    BottomNavigationBarItem(
        title: const Text("Peers"), icon: const Icon(Icons.assistant)),
    BottomNavigationBarItem(
        title: const Text("Info"), icon: const Icon(Icons.info)),
  ];

  GraphQLClient _client;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_client == null) {
      _client = GraphQLProvider.of(context).value;
    }
    if (_peersBloc == null) {
      _peersBloc = PeerBloc(_client);
    }
    if (_channelBloc == null) {
      _channelBloc = ChannelBloc(_client);
    }
    if (_nodeInfoBloc == null) {
      _nodeInfoBloc = NodeInfoBloc(_client);
    }
  }

  void nav(int index) {
    setState(() {
      _bottomNavbarIndex = index;
      switch (index) {
        case 0:
          _page = BottomNavbarPagesConn.channels;
          break;
        case 1:
          _page = BottomNavbarPagesConn.peers;
          break;
        case 2:
          _page = BottomNavbarPagesConn.node_info;
          break;
        default:
          _page = BottomNavbarPagesConn.channels;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_page) {
      case BottomNavbarPagesConn.channels:
        body = ChannelsPage(ConfigurationBloc().config.testnet);
        break;
      case BottomNavbarPagesConn.peers:
        body = PeersPage();
        break;
      case BottomNavbarPagesConn.node_info:
        body = NodeInfoPage();
        break;
      default:
        body = Center(child: Text("implement me $_page"));
    }

    return BlocProvider<PeerBloc>(
      bloc: _peersBloc,
      child: BlocProvider<ChannelBloc>(
        bloc: _channelBloc,
        child: BlocProvider(
          bloc: _nodeInfoBloc,
          child: Scaffold(
            resizeToAvoidBottomPadding: false,
            body: body,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _bottomNavbarIndex,
              onTap: nav,
              items: navItems,
            ),
          ),
        ),
      ),
    );
  }
}
