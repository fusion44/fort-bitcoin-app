/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';

class ScaleInAnimatedIcon extends StatefulWidget {
  final Duration duration;
  final double size;
  final IconData _icon;
  final Curve curve;
  final Color color;

  ScaleInAnimatedIcon(this._icon,
      {this.duration = const Duration(milliseconds: 1000),
      this.size = 200.0,
      this.curve = Curves.bounceOut,
      this.color = Colors.lightGreen});

  @override
  _ScaleInAnimatedIconState createState() => _ScaleInAnimatedIconState();
}

class _ScaleInAnimatedIconState extends State<ScaleInAnimatedIcon>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> anim;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: widget.duration, vsync: this);
    anim = CurvedAnimation(parent: controller, curve: widget.curve);
    anim.addListener(() {
      setState(() {});
    });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.size,
      child: Center(
        child: Transform.rotate(
          angle: 6.3 * anim.value,
          child: Icon(
            widget._icon,
            size: anim.value * (widget.size),
            color: widget.color,
          ),
        ),
      ),
    );
  }
}
