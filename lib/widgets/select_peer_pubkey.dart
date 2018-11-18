/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/peers_bloc.dart';
import 'package:mobile_app/gql/types/lnpeer.dart';

class SelectPeerPubkeyWidget extends StatefulWidget {
  final String initialSelection;
  final Function peerSelectedCallback;

  const SelectPeerPubkeyWidget(
      {Key key, this.peerSelectedCallback, this.initialSelection})
      : super(key: key);

  _SelectPeerPubkeyWidgetState createState() => _SelectPeerPubkeyWidgetState();
}

class _SelectPeerPubkeyWidgetState extends State<SelectPeerPubkeyWidget> {
  PeerBloc _peersBloc;
  TextEditingController _pubKeyController;
  @override
  void didChangeDependencies() {
    _pubKeyController = TextEditingController(text: widget.initialSelection);
    _peersBloc = BlocProvider.of<PeerBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child: TextField(
          decoration: InputDecoration(labelText: "Peer Public Key"),
          controller: _pubKeyController,
        )),
        IconButton(
          icon: Icon(Icons.import_contacts),
          onPressed: () {
            _showPeerSelectionDialog();
          },
        )
      ],
    );
  }

  Future<Null> _showPeerSelectionDialog() async {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        return showDialog<Null>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            _peersBloc.loadPeers();
            return createPeerSelectionDialog(context);
          },
        );
      },
    );
  }

  AlertDialog createPeerSelectionDialog(BuildContext buildContext) {
    return AlertDialog(
      title: Text("Possible Peers"),
      actions: <Widget>[
        RaisedButton(
          child: Text("OK"),
          onPressed: () => Navigator.of(buildContext).pop(),
        )
      ],
      content: BlocBuilder<PeerEvent, PeerState>(
        bloc: _peersBloc,
        builder: (BuildContext context, PeerState state) {
          bool hasPeerWithoutChannel = false;
          for (LnPeer peer in state.peers) {
            if (!peer.hasChannel) {
              hasPeerWithoutChannel = true;
              break;
            }
          }

          if (!hasPeerWithoutChannel) {
            return Text(
                "Looks like all you peers already have a channel. Please connect to one first.");
          }

          return Container(
            height: 400,
            width: 500,
            child: ListView.builder(
              itemCount: state.peers.length,
              itemBuilder: (BuildContext context, int itemId) {
                if (!state.peers[itemId].hasChannel) {
                  return ListTile(
                    title: Text(state.peers[itemId].pubKey),
                    onTap: () {
                      _peerSelected(state.peers[itemId].pubKey);
                      Navigator.of(buildContext).pop();
                    },
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  _peerSelected(String pubKey) {
    _pubKeyController.text = pubKey;
    widget.peerSelectedCallback(pubKey);
  }
}
