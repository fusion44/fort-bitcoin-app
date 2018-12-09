/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/authhelper.dart';
import 'package:mobile_app/gql/queries/payments.dart';
import 'package:mobile_app/gql/types/lninvoice.dart';
import 'package:mobile_app/gql/types/lninvoiceresponse.dart';
import 'package:mobile_app/widgets/scale_in_animated_icon.dart';
import 'package:mobile_app/widgets/show_invoice_qr.dart';
import 'package:mobile_app/widgets/simple_metric.dart';

import '../config.dart' as config;

class ReceiveLightningPage extends StatefulWidget {
  final void Function(bool onChain) _switchMode;
  ReceiveLightningPage(this._switchMode);

  @override
  _ReceiveLightningPageState createState() => _ReceiveLightningPageState();
}

enum _PageStates {
  initial,
  awaiting_new_invoice,
  awaiting_settlement,
  settled,
  show_error
}

class _ReceiveLightningPageState extends State<ReceiveLightningPage> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _memoController = TextEditingController();

  _PageStates _currentState = _PageStates.initial;
  Widget _currentPage;
  GraphQLClient _client;
  LnAddInvoiceResponse _invoice;
  LnInvoice _settledInvoice;
  SocketClient _socketClient;
  String _errorText;

  StreamSubscription<SubscriptionData> _subscription;

  var _showFAB = true;

  @override
  void dispose() {
    if (_subscription != null) _subscription.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _makeSock();
    super.didChangeDependencies();
  }

  void _makeSock() async {
    _socketClient = await SocketClient.connect(config.endPointWS, headers: {
      'content-type': 'application/json',
      'Authorization': 'JWT ${AuthHelper().user.token}'
    });
    _subscription = _socketClient
        .subscribe(SubscriptionRequest(
            "InvoicesSubscription", invoiceSubscription, {}))
        .listen((data) {
      if (_invoice == null) return;

      var sub = data.data["invoiceSubscription"];
      if (sub == null) return;

      String typename = sub["__typename"];
      switch (typename) {
        case "InvoiceSubSuccess":
          var lnAddInvoiceResponse = LnInvoice(sub["invoice"]);
          if (lnAddInvoiceResponse.paymentRequest == _invoice.paymentRequest &&
              lnAddInvoiceResponse.settled) {
            setState(() {
              _showFAB = true;
              _settledInvoice = lnAddInvoiceResponse;
              _currentState = _PageStates.settled;
            });
          }
          break;
        case "ServerError":
          print(data.data["invoiceSubscription"]["errorMessage"]);
          break;
        case "InvoiceSubError":
          break;
        default:
      }
    });
  }

  _reset() {
    this._valueController.clear();
    this._memoController.clear();
    setState(() {
      this._showFAB = true;
      this._currentState = _PageStates.initial;
      this._invoice = null;
      this._settledInvoice = null;
      this._errorText = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    _client = GraphQLProvider.of(context).value;

    switch (_currentState) {
      case _PageStates.initial:
        _currentPage = getInvoiceForm(theme);
        break;
      case _PageStates.awaiting_new_invoice:
        _currentPage = Padding(
            padding: EdgeInsets.only(top: 50.0),
            child: Center(
                child: Column(children: <Widget>[
              CircularProgressIndicator(),
              Text("Getting Invoice", style: theme.textTheme.display2)
            ])));
        break;
      case _PageStates.awaiting_settlement:
        _currentPage = Padding(
            padding: EdgeInsets.all(25.0),
            child: ShowInvoiceQr(_invoice, _valueController.value.text,
                _memoController.value.text));
        break;
      case _PageStates.settled:
        _currentPage = Column(children: <Widget>[
          ScaleInAnimatedIcon(
            Icons.check_circle_outline,
          ),
          Padding(
              padding: EdgeInsets.only(top: 25.0),
              child: Text(
                "Settled!",
                style: theme.textTheme.display3,
              )),
          Padding(
              padding: EdgeInsets.only(top: 25.0),
              child: Wrap(
                spacing: 50.0,
                runSpacing: 50.0,
                children: <Widget>[
                  SimpleMetricWidget(
                      "Received", _settledInvoice.value.toString(), "tsats"),
                  SimpleMetricWidget("Memo", _settledInvoice.memo)
                ],
              )),
          Padding(
            padding: EdgeInsets.only(top: 25.0),
            child: RaisedButton(
                onPressed: () => _reset(),
                child: Text("Awesome! New Invoice!")),
          )
        ]);
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
            )
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
                    widget._switchMode(true);
                  });
                },
                tooltip: 'Toggle mode',
                child: new Icon(Icons.linear_scale),
              )
            : Container());
  }

  Widget getInvoiceForm(ThemeData theme) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Add Invoice",
                style: theme.textTheme.display3,
              ),
              TextFormField(
                  autofocus: true,
                  controller: _valueController,
                  decoration:
                      InputDecoration(labelText: 'Invoice value in sats'),
                  keyboardType: TextInputType.numberWithOptions(
                      decimal: false, signed: false),
                  validator: (value) {
                    int sats = int.tryParse(value);

                    if (sats == null || sats <= 0) {
                      return "Must be more than 0";
                    }
                  }),
              TextFormField(
                decoration: InputDecoration(labelText: 'Optional memo'),
                controller: _memoController,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      var v = {
                        "value": int.tryParse(_valueController.value.text),
                        "memo": _memoController.value.text,
                      };

                      _client
                          .query(
                              QueryOptions(document: addInvoice, variables: v))
                          .then((data) {
                        String typename =
                            data.data["lnAddInvoice"]["result"]["__typename"];
                        switch (typename) {
                          case "AddInvoiceSuccess":
                            LnAddInvoiceResponse resp = LnAddInvoiceResponse(
                                data.data["lnAddInvoice"]["result"]["invoice"]);
                            print(resp.paymentRequest);
                            setState(() {
                              _showFAB = false;
                              _invoice = resp;
                              _currentState = _PageStates.awaiting_settlement;
                            });
                            break;
                          case "AddInvoiceError":
                            setState(() {
                              _showFAB = true;
                              _errorText = data.data["lnAddInvoice"]["result"]
                                  ["paymentError"];
                              _currentState = _PageStates.show_error;
                            });
                            break;
                          case "ServerError":
                            setState(() {
                              _showFAB = true;
                              _errorText = data.data["lnAddInvoice"]["result"]
                                  ["errorMessage"];
                              _currentState = _PageStates.show_error;
                            });
                            break;
                          default:
                            setState(() {
                              _showFAB = true;
                              _errorText = "Not implemented: $typename";
                              _currentState = _PageStates.show_error;
                            });
                        }
                      }).catchError((error) {
                        print(error);
                        setState(() {
                          _showFAB = true;
                          _errorText = error.toString();
                          _currentState = _PageStates.show_error;
                        });
                      });

                      setState(() {
                        _showFAB = true;
                        _currentState = _PageStates.awaiting_new_invoice;
                      });
                    }
                  },
                  child: Text('Create Invoice'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
