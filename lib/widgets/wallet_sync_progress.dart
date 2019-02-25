/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/blocs/wallet_info/wallet_info_state.dart';

class WalletSyncProgressWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final int _genesisBlockTime = 1231006505000;
  final WalletInfoState _state;

  WalletSyncProgressWidget(this._state);

  @override
  Widget build(BuildContext context) {
    final int timeSinceGenesis =
        DateTime.now().millisecondsSinceEpoch - _genesisBlockTime;

    if (_state.loading && _state.info.bestHeaderTimestamp == null) {
      return Text("Loading ...");
    }

    int bestHeaderTimestamp = _state.info.bestHeaderTimestamp * 1000;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
                "Chainsync at ${_state.info.formattedBestHeaderTimestamp()}"),
          ),
          LinearProgressIndicator(
              value: (1 / timeSinceGenesis) *
                  (bestHeaderTimestamp - _genesisBlockTime))
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(30.0);
}
