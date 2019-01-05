/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/invoice_list.dart';

class LightningTransfersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lightning Transfers'),
          bottom: TabBar(
            isScrollable: true,
            tabs: <Widget>[
              Tab(
                text: "Invoices",
              ),
              Tab(
                text: "Payments",
              )
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            InvoiceList(),
            ListView(children: [Text("1"), Text("2")]),
          ],
        ),
      ),
    );
  }
}
