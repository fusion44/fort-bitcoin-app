import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/gql/types/lninvoiceresponse.dart';
import 'package:mobile_app/widgets/simple_metric.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

class ShowInvoiceQr extends StatelessWidget {
  final LnAddInvoiceResponse _invoice;
  final String _value;
  final String _memo;

  const ShowInvoiceQr(this._invoice, this._value, this._memo);
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 25.0),
            child: Center(
                child: Wrap(spacing: 50.0, children: [
              SimpleMetricWidget("Request", _value, "tsats"),
              SimpleMetricWidget("Memo", _memo)
            ]))),
        Container(
          color: Colors.white,
          child: Center(
            child: QrImage(
              padding: EdgeInsets.all(25.0),
              version: 10,
              data: _invoice.paymentRequest,
            ),
          ),
        ),
        Padding(
            padding: EdgeInsets.only(top: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  iconSize: 50.0,
                  icon: Icon(Icons.assignment),
                  onPressed: () {
                    Clipboard.setData(
                        new ClipboardData(text: _invoice.paymentRequest));
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Payment request copied to clipboard")));
                  },
                ),
                IconButton(
                  iconSize: 50.0,
                  icon: Icon(Icons.share),
                  onPressed: () {
                    Share.share(_invoice.paymentRequest);
                  },
                )
              ],
            ))
      ],
    );
  }
}
