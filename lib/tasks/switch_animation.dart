// ignore_for_file: library_private_types_in_public_api

import 'package:animated_switcher_plus/animated_switcher_plus.dart';
import 'package:flutter/material.dart';

class SwitchAnimation extends StatefulWidget {
  List children;
  bool showFirst;

  SwitchAnimation(this.children, {required this.showFirst, super.key});

  @override
  _SwitchAnimationState createState() => _SwitchAnimationState();
}

class _SwitchAnimationState extends State<SwitchAnimation> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (widget.showFirst)
            AnimatedSwitcherPlus.translationBottom(
              switchInCurve: Curves.linear,
              switchOutCurve: Curves.linear,
              duration: const Duration(milliseconds: 100),
              child:
                  widget.showFirst ? widget.children.first : widget.children[1],
            ),
          if (!widget.showFirst)
            AnimatedSwitcherPlus.translationTop(
              switchInCurve: Curves.linear,
              switchOutCurve: Curves.linear,
              duration: const Duration(milliseconds: 100),
              child:
                  widget.showFirst ? widget.children.first : widget.children[1],
            ),
        ],
      ),
    );
  }
}

class PlanAnimation extends StatefulWidget {
  const PlanAnimation({super.key});

  @override
  State<PlanAnimation> createState() => _PlanAnimationState();
}

class _PlanAnimationState extends State<PlanAnimation> {
  List<Widget> subtitles = [
    const Text("per month/billed mothly", key: ValueKey(0)),
    const Text("per month/billed yearly \$82.8", key: ValueKey(1)),
  ];
  bool showFirst = true;

  List<Widget> prices = [
    const Text("\$6.9",
        key: ValueKey(2),
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
    const Text("\$8.9",
        key: ValueKey(3),
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
  ];

  void toggleTextVisibility() {
    setState(() {
      showFirst = !showFirst;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 200),
            SwitchAnimation(prices, showFirst: showFirst),
            SwitchAnimation(subtitles, showFirst: showFirst),
            ElevatedButton(
                onPressed: toggleTextVisibility, child: const Text("Change"))
          ],
        ),
      ),
    );
  }
}
