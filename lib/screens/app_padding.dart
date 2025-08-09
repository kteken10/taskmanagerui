import 'package:flutter/material.dart';

class AppPadding extends StatelessWidget {
  final Widget child;
  final double horizontalPadding;

  const AppPadding({
    super.key,
    required this.child,
    this.horizontalPadding = 16.0, // Ajuste à ta convenance
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: child,
    );
  }
}
