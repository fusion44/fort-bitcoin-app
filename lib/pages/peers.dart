/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/gql/queries/system_status.dart';
import 'package:mobile_app/gql/types/lnpeer.dart';
import 'package:mobile_app/models.dart';
import 'package:mobile_app/widgets/card_error.dart';
import 'package:mobile_app/widgets/peer_display.dart';

class PeersPage extends StatefulWidget {
  @override
  _PeersPageState createState() => _PeersPageState();
}

class _PeersPageState extends State<PeersPage> {
  bool _loading = true;
  GraphQLClient _client;
  List<Widget> _peersCards;
  String _error = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_client == null) {
      _client = GraphQLProvider.of(context).value;
    }
    _client.query(QueryOptions(document: listPeersQuery)).then((data) {
      String typename = data.data["lnListPeers"]["__typename"];
      switch (typename) {
        case "ListPeersSuccess":
          _peersCards = [];
          for (Map peer in data.data["lnListPeers"]["peers"]) {
            _peersCards.add(PeerDisplay(LnPeer(peer)));
          }
          setState(() {
            _peersCards = _peersCards;
            _loading = false;
            _error = "";
          });
          break;
        case "ListPeersError":
        case "ServerError":
          setState(() {
            _error = data.data["lnListPeers"]["errorMessage"];
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
          children: _peersCards,
        ));
  }
}
