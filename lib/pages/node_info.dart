/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/blocs/node_info_bloc.dart';
import 'package:mobile_app/widgets/show_string_qr.dart';

class NodeInfoPage extends StatefulWidget {
  _NodeInfoPageState createState() => _NodeInfoPageState();
}

class _NodeInfoPageState extends State<NodeInfoPage> {
  NodeInfoBloc _nodeInfoBloc;
  GraphQLClient _client;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_client == null) {
      _client = GraphQLProvider.of(context).value;
    }
    if (_nodeInfoBloc == null) {
      _nodeInfoBloc = BlocProvider.of<NodeInfoBloc>(context);
    }
    _nodeInfoBloc.loadNodeInfo();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return BlocBuilder<NodeInfoEvent, NodeInfoState>(
        bloc: _nodeInfoBloc,
        builder: (BuildContext context, NodeInfoState infoState) {
          String address =
              "${infoState.info.identityPubkey}@${infoState.info.currentIp}:${infoState.info.currentPort}";

          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 14.0, bottom: 8.0),
                child: Text(
                  "Node Address",
                  style: theme.textTheme.display1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                    "IP: ${infoState.info.currentIp}:${infoState.info.currentPort}"),
              ),
              ShowStringQr(address, "Address"),
            ],
          );
        });
  }
}
