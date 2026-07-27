import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';

/// Wraps content in a centered container with max width constraints on tablet/desktop.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveBreakpoints.maxContentWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final defaultPadding = isMobile
        ? EdgeInsets.zero
        : EdgeInsets.symmetric(
            horizontal: context.responsiveValue(
              mobile: 16.0,
              tablet: 24.0,
              desktop: 32.0,
            ),
          );

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding ?? defaultPadding, child: child),
      ),
    );
  }
}
