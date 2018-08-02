import 'dart:async';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/gql/queries/payments.dart';
import 'package:mobile_app/gql/types/lnpayreq.dart';
import 'package:mobile_app/gql/types/lnsendpayresult.dart';
import 'package:mobile_app/widgets/scale_in_animated_icon.dart';
import 'package:mobile_app/widgets/show_decoded_pay.dart';
import 'package:qrcode_reader/QRCodeReader.dart';

class SendPage extends StatefulWidget {
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
  show_result,
  show_result_error
}

class _SendPageState extends State<SendPage> {
  _PageStates _currentState = _PageStates.initial;
  Widget _currentPage;
  Client _client;
  LnPayReq _payReq;
  String _payReqEncoded;
  LnSendPaymentResult _result;

  @override
  Widget build(BuildContext context) {
    _client = GraphqlProvider.of(context).value;

    switch (_currentState) {
      case _PageStates.initial:
        _currentPage = Text("Waiting");
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
      body: Center(child: _currentPage),
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
    _client.query(
        query: decodePayRequest,
        variables: {"testnet": true, "payReq": req}).then((data) {
      setState(() {
        _currentState = _PageStates.show_decoded;
        _payReq = LnPayReq(data["lnDecodePayReq"]);
        _payReqEncoded = req;
      });
    });
  }

  void sendPayment(String payRequest) {
    String req = payRequest;
    if (payRequest.contains(":")) {
      req = payRequest.split(":")[1];
    }
    _client.query(
        query: sendPaymentForRequest,
        variables: {"testnet": true, "paymentRequest": req}).then((data) {
      LnSendPaymentResult res = LnSendPaymentResult(data["lnSendPayment"]);
      if (res.hasError) {
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
