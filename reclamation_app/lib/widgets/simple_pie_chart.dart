import 'package:flutter/material.dart';
import 'dart:math' as math;

class PieChartData {
  final String label;
  final int value;
  final Color color;

  PieChartData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class SimplePieChart extends StatelessWidget {
  final List<PieChartData> data;
  final String title;
  final double size;

  const SimplePieChart({
    super.key,
    required this.data,
    required this.title,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(0, (sum, item) => sum + item.value);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (total == 0)
              Center(
                child: SizedBox(
                  height: size,
                  width: size,
                  child: const Center(
                    child: Text('Aucune donnée'),
                  ),
                ),
              )
            else
              Column(
                children: [
                  CustomPaint(
                    size: Size(size, size),
                    painter: PieChartPainter(data: data, total: total),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: data.map((item) {
                      final percentage = (item.value / total * 100).toStringAsFixed(0);
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: item.color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${item.label}: ${item.value} ($percentage%)'),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<PieChartData> data;
  final int total;

  PieChartPainter({required this.data, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    double currentAngle = -math.pi / 2;

    for (final item in data) {
      final sweepAngle = (item.value / total) * 2 * math.pi;

      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        sweepAngle,
        true,
        paint,
      );

      currentAngle += sweepAngle;
    }

    // Dessiner un cercle blanc au center pour l'effet donut
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.4, centerPaint);
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
