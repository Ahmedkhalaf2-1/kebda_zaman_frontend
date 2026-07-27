import 'package:flutter/material.dart';

/// Unconstrained responsive wrapper that allows the application to utilize
/// full viewport width on Web, Desktop, Tablet, and Mobile.
class KZResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final String location;

  const KZResponsiveWrapper({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
