/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/simple_metric.dart';

class CardNodeStats extends StatelessWidget {
  final bool _loading;
  final double _uptime;
  final double _cpuUsage;
  final double _memUsed;
  final double _memTotal;
  final double _trafficIn;
  final double _trafficOut;

  CardNodeStats(
      [this._loading,
      this._uptime = 0.0,
      this._cpuUsage = 0.0,
      this._memUsed = 0.0,
      this._memTotal = 0.0,
      this._trafficIn = 0.0,
      this._trafficOut = 0.0]);

  @override
  Widget build(BuildContext context) {
    String uptime = (_uptime / 60 / 60 / 24).toStringAsFixed(1);
    String cpuUsage = _cpuUsage.toStringAsFixed(2) + " %";
    String trafficIn = (_trafficIn / 1024 / 1024).toStringAsFixed(1) + " MB";
    String trafficOut = (_trafficOut / 1024 / 1024).toStringAsFixed(1) + " MB";

    String memUsed = (_memUsed / 1024 / 1024 / 1024).toStringAsFixed(2);
    String memTotal = (_memTotal / 1024 / 1024 / 1024).toStringAsFixed(2);

    String mem = memUsed + " of " + memTotal.toString() + " GiB";
    double memPercent = (100 / _memTotal) * _memUsed;
    String memFooter = memPercent.toStringAsFixed(2) + " %";
    return Card(
        elevation: 2.0,
        margin: EdgeInsets.all(10.0),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(bottom: 5.0),
                      child: Text(
                        "System Health",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 25.0, fontWeight: FontWeight.bold),
                      ))
                ],
              ),
              _loading ? LinearProgressIndicator() : Container(),
              Wrap(
                  spacing: 15.0,
                  runSpacing: 4.0,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    SimpleMetricWidget("Uptime", uptime, "days"),
                    SimpleMetricWidget("CPU load", cpuUsage, "5m avg"),
                    SimpleMetricWidget("Traffic In", trafficIn, "24h avg"),
                    SimpleMetricWidget("Traffic Out", trafficOut, "24h avg"),
                    SimpleMetricWidget("Memory", mem, memFooter),
                  ]),
            ],
          ),
        ));
  }
}
