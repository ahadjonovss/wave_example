import 'dart:async';

import 'package:flutter/material.dart';

class RippleData {
  double height;
  double width;
  double radius;
  Color color;
  double opacity;
  double? maxHeight;
  double? maxWidth;
  double? maxRadius;
  Duration? rippleDuration;
  Duration? animationDuration;

  RippleData(
      {required this.width,
      required this.height,
      this.maxHeight,
      this.maxRadius,
      this.maxWidth,
      this.opacity = 0.1,
      this.color = Colors.transparent,
      required this.radius});

  @override
  String toString() {
    return "$height - $width - $radius";
  }
}

class CustomizableRippleAnimation extends StatefulWidget {
  Widget child;
  RippleData data;
  CustomizableRippleAnimation(
      {required this.child, required this.data, super.key});

  @override
  State<CustomizableRippleAnimation> createState() =>
      _CustomizableRippleAnimationState();
}

class _CustomizableRippleAnimationState
    extends State<CustomizableRippleAnimation> {
  Stream<RippleData> infiniteStreamOfThreeNumbers() async* {
    List ripples = [
      RippleData(
          color: widget.data.color.withOpacity(widget.data.opacity),
          width: widget.data.maxWidth ?? widget.data.width * 1.25,
          height: widget.data.maxHeight ?? widget.data.height * 2.1,
          radius: widget.data.maxRadius ?? widget.data.radius * 1.21),
      RippleData(
          color: Colors.transparent,
          width: widget.data.maxWidth ?? widget.data.width * 1.25,
          height: widget.data.maxHeight ?? widget.data.height * 2.1,
          radius: widget.data.maxRadius ?? widget.data.radius * 1.21),
      RippleData(
          color: Colors.transparent,
          width: widget.data.width,
          height: widget.data.height,
          radius: widget.data.radius),
    ];
    while (true) {
      for (RippleData i in ripples) {
        await Future.delayed(
            widget.data.rippleDuration ?? const Duration(milliseconds: 600));
        yield i;
      }
    }
  }

  late RippleData sizes;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: AnimatedContainer(
            curve: Curves.linear,
            duration: widget.data.animationDuration ??
                const Duration(milliseconds: 600),
            decoration: BoxDecoration(
                color: sizes.color,
                borderRadius: BorderRadius.all(Radius.circular(sizes.radius))),
            height: sizes.height,
            width: sizes.width,
          ),
        ),
        Center(
          child: widget.child,
        )
      ],
    );
  }

  StreamSubscription<RippleData>?
      _subscription; // StreamSubscription for managing the stream

  @override
  void initState() {
    super.initState();
    sizes = widget.data;
    _startListening();
  }

  void _startListening() {
    _subscription = infiniteStreamOfThreeNumbers().listen((size) {
      setState(() {
        sizes = size;
      });
    });
    debugPrint("Ripple has been started!");
  }

  @override
  void dispose() {
    _subscription?.cancel();
    debugPrint("Ripple has been ended!");

    super.dispose();
  }
}
