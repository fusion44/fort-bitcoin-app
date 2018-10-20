/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/gql/mutations/peers.dart';
import 'package:mobile_app/gql/queries/system_status.dart';
import 'package:mobile_app/gql/types/lnpeer.dart';
import 'package:mobile_app/models.dart';
import 'package:mobile_app/widgets/card_error.dart';
import 'package:mobile_app/widgets/connect_peer_confirm.dart';
import 'package:mobile_app/widgets/peer_display.dart';
import 'package:mobile_app/widgets/scale_in_animated_icon.dart';
import 'package:qrcode_reader/QRCodeReader.dart';
import 'package:unicorndial/unicorndial.dart';

class PeersPage extends StatefulWidget {
  @override
  _PeersPageState createState() => _PeersPageState();
}

enum _PageStates {
  initial,
  scanning,
  input_manual,
  show_data,
  connecting,
  show_error,
  show_result_error
}

class _PeersPageState extends State<PeersPage> {
  bool _loading = true;
  _PageStates _currentState = _PageStates.initial;
  Widget _currentPage;
  GraphQLClient _client;
  List<LnPeer> _peers;
  String _error = "";
  String _nodeId = "";
  String _nodeHost = "";
  BuildContext _connectingDialogContext;

  bool _permanent = false;

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
          _peers = [];
          for (Map peer in data.data["lnListPeers"]["peers"]) {
            _peers.add(LnPeer(peer));
          }
          setState(() {
            _peers = _peers;
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

  _reset() {
    if (_connectingDialogContext != null) {
      Navigator.of(_connectingDialogContext).pop();
    }

    setState(() {
      _connectingDialogContext = null;
      _nodeId = "";
      _nodeHost = "";
      _currentState = _PageStates.initial;
      _error = "";
    });
  }

  _connectManual() {
    setState(() {
      _currentState = _PageStates.input_manual;
    });
  }

  _qrScan() {
    QRCodeReader()
        .setAutoFocusIntervalInMs(200)
        .setForceAutoFocus(true)
        .setTorchEnabled(true)
        .setHandlePermissions(true)
        .setExecuteAfterPermissionGranted(true)
        .scan()
        .then((connectionInfo) {
      var split = connectionInfo.split("@");
      for (var p in _peers) {
        if (p.pubKey == split[0]) {
          setState(() {
            _currentState = _PageStates.show_result_error;
            _error = "Already connected to this peer";
          });
          return;
        }
      }
      setState(() {
        _nodeId = split[0];
        _nodeHost = split[1];
        _currentState = _PageStates.show_data;
      });
    });
    setState(() {
      _currentState = _PageStates.scanning;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return LinearProgressIndicator();

    if (_error.isNotEmpty) {
      return Column(
        children: <Widget>[
          ErrorDisplayCard("Error", [DataFetchError(0, _error, "")]),
          RaisedButton(
            child: Text("OK"),
            onPressed: () => _reset(),
          )
        ],
      );
    }

    ThemeData theme = Theme.of(context);
    switch (_currentState) {
      case _PageStates.initial:
        _currentPage = _buildInitialPage(theme);
        break;
      case _PageStates.scanning:
        _currentPage = Container();
        break;
      case _PageStates.show_data:
        _currentPage = ConnectPeerConfirmWidget(
          _nodeId,
          _nodeHost,
          _connectPeer,
          () => _reset(),
          (bool state) {
            _permanent = state;
          },
        );
        break;
      default:
        print("Implement me $_currentState");
    }

    return _currentPage;
  }

  Widget _buildInitialPage(ThemeData theme) {
    var childButtons = List<UnicornButton>();

    childButtons.add(UnicornButton(
        currentButton: FloatingActionButton(
            onPressed: this._qrScan,
            heroTag: "qr-scan",
            backgroundColor: theme.accentColor,
            mini: true,
            child: Icon(Icons.photo_camera))));

    childButtons.add(UnicornButton(
        currentButton: FloatingActionButton(
            onPressed: this._connectManual,
            heroTag: "manual",
            backgroundColor: theme.accentColor,
            mini: true,
            child: Icon(Icons.keyboard))));

    var peerCards = List<PeerDisplay>();
    for (var p in _peers) peerCards.add(PeerDisplay(p));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          print("TODO: Refresh");
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: peerCards,
        ),
      ),
      floatingActionButton: UnicornDialer(
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.0),
        parentButtonBackground: theme.accentColor,
        orientation: UnicornOrientation.VERTICAL,
        parentButton: Icon(Icons.add),
        childButtons: childButtons,
      ),
    );
  }

  void _connectPeer() {
    _showConnectingDialog();

    var v = {"pubkey": _nodeId, "host": _nodeHost, "perm": _permanent};
    _client
        .query(QueryOptions(document: connectPeerMutation, variables: v))
        .then((data) {
      String typename = data.data["lnConnectPeer"]["__typename"];
      switch (typename) {
        case "ConnectPeerSuccess":
          _reset();
          _showConnectSuccessDialog();
          break;
        case "ServerError":
        case "ConnectPeerError":
          if (_connectingDialogContext != null) {
            Navigator.of(_connectingDialogContext).pop();
          }
          setState(() {
            _connectingDialogContext = null;
            _currentState = _PageStates.show_error;
            _error = data.data["lnConnectPeer"]["errorMessage"];
          });
          break;
        default:
          break;
      }
    }).catchError((err) {
      setState(() {
        _currentState = _PageStates.show_error;
        _error = err.toString();
      });
    });
  }

  Future<Null> _showConnectingDialog() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        _connectingDialogContext = context;
        return AlertDialog(
          title: Text('Connecting!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[CircularProgressIndicator()],
            ),
          ),
        );
      },
    );
  }

  Future<Null> _showConnectSuccessDialog() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Connected!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ScaleInAnimatedIcon(
                  Icons.check_circle_outline,
                  size: 150.0,
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
