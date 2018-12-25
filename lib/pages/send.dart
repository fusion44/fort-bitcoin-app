/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/gql/queries/payments.dart';
import 'package:mobile_app/gql/types/lnpayreq.dart';
import 'package:mobile_app/gql/types/lnsendpayresult.dart';
import 'package:mobile_app/models.dart';
import 'package:mobile_app/widgets/scale_in_animated_icon.dart';
import 'package:mobile_app/widgets/show_decoded_pay.dart';
import 'package:qrcode_reader/qrcode_reader.dart';

class SendPage extends StatefulWidget {
  static IconData icon = Icons.send;
  static String appBarText = "Send";

  SendPage({Key key, this.title}) : super(key: key);

  final String title;

  final Map<String, dynamic> pluginParameters = {};

  @override
  _SendPageState createState() => new _SendPageState();
}

enum _PageStates {
  initial,
  scanning,
  decoding,
  show_decoded,
  sending,
  show_error, // local errors (node not reachable etc.)
  show_result,
  show_result_error // errors during payment from server
}

class _SendPageState extends State<SendPage> {
  _PageStates _currentState = _PageStates.initial;
  Widget _currentPage;
  GraphQLClient _client;
  LnPayReq _payReq;
  String _payReqEncoded;
  LnSendPaymentResult _result;
  String _errorText;
  final _invoiceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _client = GraphQLProvider.of(context).value;

    switch (_currentState) {
      case _PageStates.initial:
        _currentPage = Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                maxLines: 5,
                autofocus: false,
                controller: _invoiceController,
                decoration:
                    InputDecoration(labelText: "Paste your invoice here"),
              ),
            ),
            RaisedButton(
              child: Text("Check Invoice"),
              onPressed: () {
                setState(() {
                  _currentState = _PageStates.decoding;
                });
                checkPayRequest(_invoiceController.value.text);
              },
            )
          ],
        );
        break;
      case _PageStates.scanning:
        _currentPage = Container();
        break;
      case _PageStates.decoding:
        _currentPage = Column(children: [
          Text(
            "Decoding ...",
            style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
          ),
          CircularProgressIndicator()
        ]);
        break;
      case _PageStates.show_decoded:
        _currentPage = Padding(
            padding: EdgeInsets.all(15.0),
            child: ListView(children: <Widget>[
              ShowDecodedPay(_payReq),
              IconButton(
                iconSize: 66.0,
                icon: Icon(
                  Icons.send,
                  color: Colors.redAccent,
                ),
                onPressed: () {
                  setState(() {
                    _currentState = _PageStates.sending;
                  });
                  sendPayment(_payReqEncoded);
                },
              )
            ]));
        break;
      case _PageStates.sending:
        _currentPage = Column(children: [
          Text(
            "Sending ...",
            style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
          ),
          CircularProgressIndicator()
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
      case _PageStates.show_result:
        _currentPage = Column(children: <Widget>[
          ScaleInAnimatedIcon(
            Icons.check_circle_outline,
          ),
          Text("123")
        ]);
        break;
      case _PageStates.show_result_error:
        _currentPage = Column(
          children: <Widget>[
            ScaleInAnimatedIcon(
              Icons.error_outline,
              color: Colors.redAccent,
            ),
            Text(
              _result.paymentError,
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
      floatingActionButton: _currentState == _PageStates.initial
          ? FloatingActionButton(
              onPressed: () {
                QRCodeReader()
                    .setAutoFocusIntervalInMs(200)
                    .setForceAutoFocus(true)
                    .setTorchEnabled(true)
                    .setHandlePermissions(true)
                    .setExecuteAfterPermissionGranted(true)
                    .scan()
                    .then((barcodeString) {
                  setState(() {
                    _currentState = _PageStates.decoding;
                  });
                  checkPayRequest(barcodeString);
                });
              },
              tooltip: 'Reader the QRCode',
              child: new Icon(Icons.add_a_photo),
            )
          : Container(),
    );
  }

  void checkPayRequest(String payRequest) {
    String req = payRequest;
    if (payRequest.contains(":")) {
      req = payRequest.split(":")[1];
    }
    _client
        .query(QueryOptions(
            document: decodePayRequest, variables: {"payReq": req}))
        .then((data) {
      var lnDecodePayReq = data.data["lnDecodePayReq"];
      switch (lnDecodePayReq["__typename"]) {
        case "DecodePayReqSuccess":
          setState(() {
            _currentState = _PageStates.show_decoded;
            _payReq = LnPayReq(lnDecodePayReq["lnTransactionDetails"]);
            _payReqEncoded = req;
          });
          break;
        case "ServerError":
          setState(() {
            _currentState = _PageStates.show_error;
            _errorText = lnDecodePayReq["errorMessage"];
          });
          print("Error decoding invoice ${lnDecodePayReq["errorMessage"]}");
          break;
        default:
          setState(() {
            _currentState = _PageStates.show_error;
            _errorText = "Not implemented: ${lnDecodePayReq["__typename"]}";
          });
      }
    }).catchError((error) {
      setState(() {
        _currentState = _PageStates.show_error;
        _errorText = error.toString();
      });
      print(error);
    });
  }

  void sendPayment(String payRequest) {
    String req = payRequest;
    if (payRequest.contains(":")) {
      req = payRequest.split(":")[1];
    }
    _client
        .query(QueryOptions(
            document: sendPaymentForRequest,
            variables: {"payReq": req},
            fetchPolicy: FetchPolicy.networkOnly))
        .then((data) {
      if (data.errors == null) {
        LnSendPaymentResult res =
            LnSendPaymentResult(data.data["lnSendPayment"]["paymentResult"]);
        if (res.hasError) {
          // process payment errors
          setState(() {
            _currentState = _PageStates.show_result_error;
            _result = res;
          });
        } else {
          setState(() {
            _currentState = _PageStates.show_result;
            _result = res;
          });
        }
      } else {
        Map<String, DataFetchError> errors = Map();

        for (var error in data.errors) {
          int code;
          String message;
          jsonDecode(error.message, reviver: (k, v) {
            if (k == "code") {
              code = v;
            } else if (k == "message") {
              message = v;
            }
          });
          DataFetchError err = DataFetchError(code, message, error.path[0]);
          errors[err.path] = err;
        }

        setState(() {
          // process erros due to node failures
          _currentState = _PageStates.show_error;
          _errorText = "";
        });
      }
    }).catchError((error) {
      String err = "Server Error: " + error.toString();
      LnSendPaymentResult res = LnSendPaymentResult({"paymentError": err});
      setState(() {
        _currentState = _PageStates.show_result_error;
        _result = res;
      });
    });
  }
}
