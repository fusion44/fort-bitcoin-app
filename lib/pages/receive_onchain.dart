/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/gql/queries/payments.dart';
import 'package:mobile_app/widgets/scale_in_animated_icon.dart';
import 'package:mobile_app/widgets/show_string_qr.dart';

class ReceiveOnchainPage extends StatefulWidget {
  final void Function(bool onChain) _switchMode;
  ReceiveOnchainPage(this._switchMode);

  _ReceiveOnchainPageState createState() => _ReceiveOnchainPageState();
}

enum _PageStates { initial, awaiting_address, show_address, show_error }

class _ReceiveOnchainPageState extends State<ReceiveOnchainPage> {
  _PageStates _currentState = _PageStates.initial;
  Widget _currentPage;
  GraphQLClient _client;
  String _address;
  String _errorText;
  bool _showFAB = true;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    _client = GraphQLProvider.of(context).value;

    switch (_currentState) {
      case _PageStates.initial:
        _currentPage = Center(
            child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 80.0, bottom: 15.0),
              child: Text("Get a new on chain address",
                  style: theme.textTheme.display1.copyWith(fontSize: 20.0)),
            ),
            new RaisedButton(
                child: Text("new address"), onPressed: _getNewAddress)
          ],
        ));
        break;
      case _PageStates.awaiting_address:
        _currentPage = Padding(
            padding: EdgeInsets.only(top: 50.0),
            child: Center(
                child: Column(children: <Widget>[
              CircularProgressIndicator(),
              Text("Getting Address", style: theme.textTheme.display2)
            ])));
        break;
      case _PageStates.show_address:
        _currentPage = Padding(
            padding: EdgeInsets.all(25.0),
            child: ShowStringQr(_address, "Address"));
        break;
      case _PageStates.show_error:
        _currentPage = Column(
          children: <Widget>[
            ScaleInAnimatedIcon(
              Icons.error_outline,
              color: Colors.redAccent,
            ),
            Text(
              _errorText,
              style: TextStyle(color: Colors.red, fontSize: 25.0),
            ),
            Padding(
                padding: EdgeInsets.only(top: 25.0),
                child: RaisedButton(
                  child: Text("Retry"),
                  onPressed: () {
                    setState(() {
                      _showFAB = true;
                      _address = "";
                      _currentState = _PageStates.initial;
                      _errorText = "";
                    });
                  },
                ))
          ],
        );
        break;
      default:
        _currentPage = Text("Should not see this");
    }

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: _currentPage,
        floatingActionButton: _showFAB
            ? FloatingActionButton(
                onPressed: () {
                  setState(() {
                    widget._switchMode(false);
                  });
                },
                tooltip: 'Toggle mode',
                child: new Icon(Icons.offline_bolt),
              )
            : Container());
  }

  void _getNewAddress() {
    setState(() {
      _showFAB = false;
      _currentState = _PageStates.awaiting_address;

      _client.query(QueryOptions(document: newOnchainAddress)).then((value) {
        var data = value.data["lnNewAddress"];
        String typename = data["__typename"];
        switch (typename) {
          case "NewAddressSuccess":
            setState(() {
              _currentState = _PageStates.show_address;
              _address = data["address"];
            });
            break;
          case "NewAddressError":
          case "ServerError":
            _errorText = data["errorMessage"];
            setState(() {
              _currentState = _PageStates.show_error;
            });
            break;
          default:
        }
      }).catchError((err) {
        setState(() {
          _currentState = _PageStates.show_error;
          _errorText = err.toString();
        });
        print(err);
      });
    });
  }
}
