/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/authhelper.dart';
import 'package:mobile_app/gql/queries/payments.dart';
import 'package:mobile_app/gql/types/lninvoice.dart';
import 'package:mobile_app/gql/types/lninvoiceresponse.dart';
import 'package:mobile_app/pages/receive_lightning.dart';
import 'package:mobile_app/pages/receive_onchain.dart';
import 'package:mobile_app/widgets/scale_in_animated_icon.dart';
import 'package:mobile_app/widgets/show_invoice_qr.dart';
import 'package:mobile_app/widgets/simple_metric.dart';

import '../config.dart' as config;

class ReceivePage extends StatefulWidget {
  static IconData icon = Icons.info;
  static String appBarText = "Receive";

  ReceivePage({Key key, this.title}) : super(key: key);

  final String title;

  final Map<String, dynamic> pluginParameters = {};

  @override
  _ReceivePageState createState() => _ReceivePageState();
}

enum _PageStates {
  initial,
  awaiting_new_invoice,
  awaiting_settlement,
  settled,
  show_error
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
    return _onChain
        ? ReceiveOnchainPage(this._switchMode)
        : ReceiveLightningPage(this._switchMode);
  }
}
