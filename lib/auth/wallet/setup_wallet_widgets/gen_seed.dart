/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/common/types/lnseed.dart';

class RowEntry extends StatefulWidget {
  final int pos;
  final String text;

  RowEntry(this.pos, this.text);

  _RowEntryState createState() => _RowEntryState();
}

class _RowEntryState extends State<RowEntry> {
  bool _touched = false;

  @override
  Widget build(BuildContext context) {
    TextStyle untouched =
        Theme.of(context).textTheme.headline.copyWith(fontSize: 21.0);
    TextStyle touched = Theme.of(context).textTheme.headline.copyWith(
        fontSize: 18.0,
        decoration: TextDecoration.underline,
        color: Colors.greenAccent);

    return Expanded(
      child: InkWell(
        child: Row(
          children: <Widget>[
            Container(width: 20.0, child: Text(widget.pos.toString())),
            Text(widget.text, style: _touched ? touched : untouched)
          ],
        ),
        onTap: () {
          setState(() {
            _touched = !_touched;
          });
        },
      ),
    );
  }
}

class SeedRow extends StatelessWidget {
  final int row;
  final List<String> seedList;
  SeedRow(this.row, this.seedList) {
    if (this.seedList.length != 3) {
      throw ArgumentError("Length of seedList must be exactly three");
    }
  }

  @override
  Widget build(BuildContext context) {
    int base = row * 3;
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          RowEntry(base + 1, seedList[0]),
          RowEntry(base + 2, seedList[1]),
          RowEntry(base + 3, seedList[2])
        ],
      ),
    );
  }
}

class GenSeedWidget extends StatelessWidget {
  final LnSeed _seed;
  final bool _loading;
  final dynamic onNewSeedCallback;
  GenSeedWidget(this._seed, this._loading, this.onNewSeedCallback);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    var rows = <SeedRow>[];
    if (_seed != null) {
      var temp = <String>[];
      int row = 0;
      for (String s in _seed.cipherSeedMnemonic) {
        temp.add(s);
        if (temp.length == 3) {
          rows.add(SeedRow(row, temp));
          temp = <String>[];
          row++;
        }
      }
    }

    TextStyle ts = theme.textTheme.headline
        .copyWith(color: Colors.redAccent, fontSize: 20.0);
    return Column(
      children: <Widget>[
        !_loading
            ? Text("Please write this seed down and store it in a safe place.",
                style: ts)
            : Container(),
        !_loading
            ? IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  this.onNewSeedCallback();
                },
              )
            : Container(),
        _loading ? LinearProgressIndicator() : Container(),
        Wrap(
          runSpacing: 9.0,
          children: rows,
        ),
      ],
    );
  }
}
