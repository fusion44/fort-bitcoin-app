/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/common/types/lnpeer.dart';
import 'package:mobile_app/connectivity/peer/connect_peer_confirm_widget.dart';
import 'package:mobile_app/connectivity/peer/peer.dart';
import 'package:mobile_app/connectivity/peer/peer_display_widget.dart';
import 'package:qrcode_reader/qrcode_reader.dart';
import 'package:unicorndial/unicorndial.dart';

String disconnectPeerMutation = """
mutation DisconnectPeer(\$pubkey: String!) {
  lnDisconnectPeer(pubkey: \$pubkey) {
    __typename
    ... on DisconnectPeerSuccess {
      result
      pubkey
    }
    ... on ServerError {
      errorMessage
    }
    ... on DisconnectPeerError {
      errorMessage
      pubkey
    }
  }
}
""";

class PeerPage extends StatefulWidget {
  @override
  _PeerPageState createState() => _PeerPageState();
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

class _PeerPageState extends State<PeerPage> {
  _PageStates _currentState = _PageStates.initial;
  Widget _currentPage;
  GraphQLClient _client;
  PeerBloc _peerBloc;
  List<LnPeer> _peers;
  String _error = "";
  String _nodeId = "";
  String _nodeHost = "";
  BuildContext _connectingDialogContext;
  final _formKey = GlobalKey<FormState>();
  final _combinedController = TextEditingController();
  bool _permanent = false;
  Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_client == null) {
      _client = GraphQLProvider.of(context).value;
    }
    if (_peerBloc == null) {
      _peerBloc = BlocProvider.of<PeerBloc>(context);
    }
    _peerBloc.loadPeers();
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
    return BlocBuilder<PeerEvent, PeerState>(
      bloc: _peerBloc,
      builder: (
        BuildContext context,
        PeerState peerState,
      ) {
        if (peerState.type == PeerEventType.startConnectPeer) {
          _showConnectingDialog();
        } else if (peerState.type == PeerEventType.finishConnectPeer) {
          if (_connectingDialogContext != null) {
            Navigator.of(_connectingDialogContext).pop();
            _connectingDialogContext = null;
          }
          if (peerState.error.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              Scaffold.of(context).showSnackBar(
                SnackBar(content: Text(peerState.error)),
              );
            });
          }
        }

        ThemeData theme = Theme.of(context);
        _peers = peerState.peers;

        switch (_currentState) {
          case _PageStates.initial:
            _currentPage = _buildInitialPage(peerState, theme);
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
          case _PageStates.show_result_error:
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              Scaffold.of(context).showSnackBar(
                SnackBar(content: Text(_error)),
              );
              _reset();
            });
            break;
          default:
            print("Implement me $_currentState");
        }

        return _currentPage;
      },
    );
  }

  Widget _buildInitialPage(PeerState peerState, ThemeData theme) {
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
            onPressed: () => _showConnectManInputDialog(),
            heroTag: "manual",
            backgroundColor: theme.accentColor,
            mini: true,
            child: Icon(Icons.keyboard))));

    var peerCards = List<Widget>();

    for (var p in peerState.peers) {
      peerCards.add(PeerDisplayWidget(p, _disconnectPeer));
    }

    if (peerState.type == PeerEventType.finishLoading) {
      _refreshCompleter?.complete();
      _refreshCompleter = Completer();
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _peerBloc.dispatch(LoadPeers(true));
          return _refreshCompleter.future;
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

  _disconnectPeer(key) async {
    try {
      QueryResult result = await _client.query(QueryOptions(
          document: disconnectPeerMutation, variables: {"pubkey": key}));

      String typename = result.data["lnDisconnectPeer"]["__typename"];
      switch (typename) {
        case "DisconnectPeerSuccess":
          _peers.retainWhere((LnPeer peer) {
            return peer.pubKey != key;
          });
          setState(() {
            _peers = _peers;
          });
          break;
        case "ServerError":
        case "DisconnectPeerError":
          setState(() {
            _currentState = _PageStates.show_error;
            _error = result.data["lnDisconnectPeer"]["errorMessage"];
          });
          break;
        default:
          print("Implement me $typename");
      }
    } catch (e) {
      setState(() {
        _currentState = _PageStates.show_error;
        _error = e.toString();
      });
      print(e);
    }
  }

  _connectPeer() {
    _currentState = _PageStates.initial;
    _peerBloc.connectPeer(_nodeId, _nodeHost, _permanent);
  }

  Future<Null> _showConnectManInputDialog() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter peer address'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      autofocus: true,
                      controller: _combinedController,
                      decoration: InputDecoration(
                          labelText: 'Enter full address (pubkey@host:port)'),
                      validator: (value) {
                        if (value.isNotEmpty && !value.contains("@") ||
                            !value.contains(":")) {
                          return "Format: pubkey@host:port";
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  var split = _combinedController.value.text.split("@");
                  Navigator.of(context).pop();
                  setState(() {
                    _nodeId = split[0];
                    _nodeHost = split[1];
                    _currentState = _PageStates.show_data;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<Null> _showConnectingDialog() async {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
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
      },
    );
  }
}
