import 'dart:math' as math;

import 'package:flutter/material.dart';

class GlareDecoration extends StatefulWidget {
  GlareDecoration({Key? key}) : super(key: key);

  @override
  _GlareDecorationState createState() => _GlareDecorationState();
}

class _GlareDecorationState extends State<GlareDecoration> with SingleTickerProviderStateMixin {
  AnimationController? _glareController;
  late Animation<double> _glareAnimation;
  late List<Color> _glareColors;
  late List<double> _glareStops;

  @override
  void initState() {
    super.initState();

    _glareColors = [
      Colors.transparent,
      Colors.grey.withAlpha(140),
      Colors.transparent,
      Colors.transparent,
      Colors.transparent,
      Colors.grey.withAlpha(140),
    ];

    _glareStops = List<double>.generate(_glareColors.length, (index) => index * (1 / _glareColors.length.toDouble()));

    _glareController = AnimationController(duration: Duration(milliseconds: 2000), vsync: this);
    _glareAnimation = Tween<double>(begin: .0, end: 1.0).animate(_glareController!)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _glareController!.reset();
          _glareController!.forward();
        } else if (status == AnimationStatus.dismissed) {
          _glareController!.forward();
        }
      });
    _glareController!.forward();
  }

  @override
  dispose() {
    _glareController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          transform: GradientRotation(math.pi / 12),
          colors: _glareColors,
          stops: _glareStops.map((s) => (s + _glareAnimation.value)).toList(),
        ),
      ),
    );
  }
}
