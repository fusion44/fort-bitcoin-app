/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/auth/auth/authentication.dart';
import 'package:mobile_app/balance/invoice/receive_lightning_page.dart';
import 'package:mobile_app/balance/onchain_data/receive_onchain_page.dart';

class ReceivePage extends StatefulWidget {
  static IconData icon = Icons.info;
  static String appBarText = "Receive";

  ReceivePage({Key key, this.title}) : super(key: key);

  final String title;

  final Map<String, dynamic> pluginParameters = {};

  @override
  _ReceivePageState createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  bool _onChain = false;

  void _switchMode(bool onChain) {
    setState(() {
      _onChain = onChain;
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthenticationBloc bloc = BlocProvider.of<AuthenticationBloc>(context);

    return _onChain
        ? ReceiveOnchainPage(this._switchMode)
        : ReceiveLightningPage(
            this._switchMode, bloc.userRepository.user.token);
  }
}
