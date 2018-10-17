/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/gql/queries/system_status.dart';
import 'package:mobile_app/gql/types/lnchannel.dart';
import 'package:mobile_app/models.dart';
import 'package:mobile_app/widgets/card_error.dart';
import 'package:mobile_app/widgets/channel_display.dart';

class ChannelsPage extends StatefulWidget {
  final bool _testnet;

  ChannelsPage([this._testnet = false]);

  @override
  _ChannelsPageState createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> {
  bool _loading = true;
  GraphQLClient _client;
  List<Widget> _channelCards;
  String _error = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_client == null) {
      _client = GraphQLProvider.of(context).value;
    }
    _client.query(QueryOptions(document: listChannelsQuery)).then((data) {
      String typename = data.data["lnListChannels"]["__typename"];
      switch (typename) {
        case "ListChannelsSuccess":
          _channelCards = [];
          for (Map chan in data.data["lnListChannels"]["channels"]) {
            _channelCards.add(ChannelDisplay(LnChannel(chan)));
          }
          setState(() {
            _channelCards = _channelCards;
            _loading = false;
            _error = "";
          });
          break;
        case "ListChannelsError":
        case "ServerError":
          setState(() {
            _error = data.data["lnListChannels"]["errorMessage"];
            _loading = false;
          });
          break;
        default:
      }
    }).catchError((error) {
      setState(() {
        _error = error.toString();
        _loading = false;
      });
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return LinearProgressIndicator();

    if (_error.isNotEmpty) {
      return ErrorDisplayCard("Error", [DataFetchError(0, _error, "")]);
    }

    return RefreshIndicator(
        onRefresh: () async {
          print("TODO: Refresh");
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: _channelCards,
        ));
  }
}
