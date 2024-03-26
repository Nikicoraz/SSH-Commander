
import 'package:flutter/material.dart';

class GrayBorderSection extends StatelessWidget {
  final Widget child;
  final double height;

  const GrayBorderSection({super.key, required this.child, this.height = -1});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height == -1 ? null : height,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: child,
    );
  }
}