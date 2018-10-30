import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

class ShowStringQr extends StatelessWidget {
  final String _description;
  final String _value;

  const ShowStringQr(this._value, [this._description = ""]);
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double width65Percent = width * 0.65;

    return Column(
      children: <Widget>[
        Container(
          width: width65Percent,
          color: Colors.white,
          child: Center(
            child: QrImage(
              padding: EdgeInsets.all(10.0),
              version: 10,
              data: _value,
            ),
          ),
        ),
        Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  iconSize: 50.0,
                  icon: Icon(Icons.assignment),
                  onPressed: () {
                    Clipboard.setData(new ClipboardData(text: _value));
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("$_description copied to clipboard")));
                  },
                ),
                IconButton(
                  iconSize: 50.0,
                  icon: Icon(Icons.share),
                  onPressed: () {
                    Share.share(_value);
                  },
                )
              ],
            ))
      ],
    );
  }
}
