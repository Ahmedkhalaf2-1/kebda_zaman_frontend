import 'package:flutter/material.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/features/admin/domain/models/report_models.dart';

/// A lightweight, dependency-free revenue chart with a compact order-volume
/// bar row underneath, drawn with [CustomPainter] — no charting package is
/// in `pubspec.yaml`, and this dashboard's needs (one revenue line + one
/// secondary volume series, already gap-filled/sorted by the backend) don't
/// justify adding one.
class KZSalesChart extends StatefulWidget {
  final List<SalesPeriodPoint> points;
  final ReportGroupBy groupBy;

  const KZSalesChart({super.key, required this.points, required this.groupBy});

  @override
  State<KZSalesChart> createState() => _KZSalesChartState();
}

class _KZSalesChartState extends State<KZSalesChart> {
  int? _hoverIndex;

  String _formatPeriodLabel(String period) {
    // "YYYY-MM-DD" or "YYYY-MM" — display only the trailing, most relevant
    // segment so labels stay short and never clip on small screens.
    final parts = period.split('-');
    if (widget.groupBy == ReportGroupBy.month && parts.length == 2) {
      return '${parts[1]}/${parts[0].substring(2)}';
    }
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}';
    }
    return period;
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.points;
    if (points.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: SizedBox.shrink()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const height = 220.0;

        return MouseRegion(
          onHover: (event) => _updateHover(event.localPosition, width),
          onExit: (_) => setState(() => _hoverIndex = null),
          child: GestureDetector(
            onTapDown: (details) => _updateHover(details.localPosition, width),
            onHorizontalDragUpdate: (details) =>
                _updateHover(details.localPosition, width),
            child: SizedBox(
              width: width,
              height: height,
              child: CustomPaint(
                painter: _SalesChartPainter(
                  points: points,
                  hoverIndex: _hoverIndex,
                  labelFormatter: _formatPeriodLabel,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateHover(Offset localPosition, double width) {
    final points = widget.points;
    if (points.isEmpty) return;
    const leftPad = 44.0;
    const rightPad = 12.0;
    final plotWidth = (width - leftPad - rightPad).clamp(1.0, double.infinity);
    final relativeX = (localPosition.dx - leftPad).clamp(0.0, plotWidth);
    final step = points.length > 1 ? plotWidth / (points.length - 1) : 0.0;
    final index = step > 0
        ? (relativeX / step).round().clamp(0, points.length - 1)
        : 0;
    if (index != _hoverIndex) setState(() => _hoverIndex = index);
  }
}

class _SalesChartPainter extends CustomPainter {
  final List<SalesPeriodPoint> points;
  final int? hoverIndex;
  final String Function(String) labelFormatter;

  _SalesChartPainter({
    required this.points,
    required this.hoverIndex,
    required this.labelFormatter,
  });

  static const _leftPad = 44.0;
  static const _rightPad = 12.0;
  static const _topPad = 16.0;
  static const _bottomPad = 34.0;
  static const _barAreaHeight = 28.0;

  @override
  void paint(Canvas canvas, Size size) {
    final maxRevenue = points
        .map((p) => p.revenue)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final maxOrders = points
        .map((p) => p.orderCount)
        .fold<int>(0, (a, b) => a > b ? a : b);

    final plotWidth = (size.width - _leftPad - _rightPad).clamp(
      1.0,
      double.infinity,
    );
    final lineAreaHeight =
        size.height - _topPad - _bottomPad - _barAreaHeight - 8;
    const lineAreaTop = _topPad;

    // Grid + y-axis labels (0, mid, max revenue).
    final gridPaint = Paint()
      ..color = KZ.outlineVariant.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    const labelStyle = TextStyle(
      fontFamily: 'Readex Pro',
      fontSize: 10,
      color: KZ.secondary,
    );
    for (final fraction in [0.0, 0.5, 1.0]) {
      final y = lineAreaTop + lineAreaHeight * (1 - fraction);
      canvas.drawLine(
        Offset(_leftPad, y),
        Offset(size.width - _rightPad, y),
        gridPaint,
      );
      final value = maxRevenue * fraction;
      final tp = TextPainter(
        text: TextSpan(text: value.toStringAsFixed(0), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    if (maxRevenue <= 0 && maxOrders <= 0) {
      return; // zero-data period: grid only, no misleading flat line.
    }

    double xForIndex(int i) =>
        _leftPad +
        (points.length > 1 ? plotWidth * i / (points.length - 1) : 0);

    // Revenue line + gradient fill.
    final linePath = Path();
    final fillPath = Path();
    for (var i = 0; i < points.length; i++) {
      final x = xForIndex(i);
      final ratio = maxRevenue > 0 ? points[i].revenue / maxRevenue : 0.0;
      final y = lineAreaTop + lineAreaHeight * (1 - ratio);
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, lineAreaTop + lineAreaHeight);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      if (i == points.length - 1) {
        fillPath.lineTo(x, lineAreaTop + lineAreaHeight);
        fillPath.close();
      }
    }

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                KZ.primary.withValues(alpha: 0.22),
                KZ.primary.withValues(alpha: 0.0),
              ],
            ).createShader(
              Rect.fromLTWH(_leftPad, lineAreaTop, plotWidth, lineAreaHeight),
            ),
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..color = KZ.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Order-volume bars beneath the line chart.
    final barTop = lineAreaTop + lineAreaHeight + 20;
    final barWidth = points.isNotEmpty
        ? (plotWidth / points.length * 0.5).clamp(2.0, 18.0)
        : 4.0;
    final barPaint = Paint()
      ..color = KZ.primaryContainer.withValues(alpha: 0.5);
    for (var i = 0; i < points.length; i++) {
      final x = xForIndex(i);
      final ratio = maxOrders > 0 ? points[i].orderCount / maxOrders : 0.0;
      final barHeight = _barAreaHeight * ratio;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x - barWidth / 2,
            barTop + (_barAreaHeight - barHeight),
            barWidth,
            barHeight,
          ),
          const Radius.circular(2),
        ),
        barPaint,
      );
    }

    // X-axis labels — thin out to avoid clipping on narrow screens.
    final maxLabels = (plotWidth / 56).floor().clamp(2, points.length);
    final labelStep = (points.length / maxLabels).ceil().clamp(
      1,
      points.length,
    );
    for (var i = 0; i < points.length; i += labelStep) {
      final x = xForIndex(i);
      final tp = TextPainter(
        text: TextSpan(
          text: labelFormatter(points[i].period),
          style: labelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - _bottomPad + 12));
    }

    // Hover/tap indicator + tooltip.
    if (hoverIndex != null && hoverIndex! < points.length) {
      final i = hoverIndex!;
      final x = xForIndex(i);
      final point = points[i];
      canvas.drawLine(
        Offset(x, lineAreaTop),
        Offset(x, lineAreaTop + lineAreaHeight),
        Paint()
          ..color = KZ.primary.withValues(alpha: 0.3)
          ..strokeWidth = 1,
      );
      final ratio = maxRevenue > 0 ? point.revenue / maxRevenue : 0.0;
      final dotY = lineAreaTop + lineAreaHeight * (1 - ratio);
      canvas.drawCircle(Offset(x, dotY), 4, Paint()..color = KZ.primary);

      final tooltipLines = [
        labelFormatter(point.period),
        point.revenue.toStringAsFixed(0),
        '${point.orderCount}',
      ];
      final tp = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${tooltipLines[0]}\n',
              style: labelStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: tooltipLines[1],
              style: labelStyle.copyWith(color: Colors.white),
            ),
          ],
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final boxWidth = tp.width + 16;
      final boxHeight = tp.height + 12;
      var boxX = x - boxWidth / 2;
      boxX = boxX.clamp(0.0, size.width - boxWidth);
      final boxY = (dotY - boxHeight - 10).clamp(0.0, size.height);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(boxX, boxY, boxWidth, boxHeight),
          const Radius.circular(8),
        ),
        Paint()..color = KZ.onSurface.withValues(alpha: 0.92),
      );
      tp.paint(canvas, Offset(boxX + 8, boxY + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _SalesChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.hoverIndex != hoverIndex;
  }
}
