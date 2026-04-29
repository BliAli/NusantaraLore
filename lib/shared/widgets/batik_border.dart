import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class BatikBorder extends StatelessWidget {
  final Widget child;
  final double width;
  final Color color;

  const BatikBorder({
    super.key,
    required this.child,
    this.width = 2,
    this.color = kColorSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: width),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CustomPaint(
          painter: _BatikPatternPainter(color: color.withValues(alpha: 0.1)),
          child: child,
        ),
      ),
    );
  }
}

class _BatikPatternPainter extends CustomPainter {
  final Color color;

  _BatikPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 3, paint);
        if ((x ~/ spacing + y ~/ spacing) % 2 == 0) {
          canvas.drawRect(
            Rect.fromCenter(center: Offset(x, y), width: 8, height: 8),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BatikDivider extends StatelessWidget {
  final double height;
  final Color color;

  const BatikDivider({
    super.key,
    this.height = 2,
    this.color = kColorSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height + 8),
      painter: _BatikDividerPainter(color: color),
    );
  }
}

class _BatikDividerPainter extends CustomPainter {
  final Color color;

  _BatikDividerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final y = size.height / 2;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

    const spacing = 15.0;
    for (double x = spacing / 2; x < size.width; x += spacing) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 6, height: 4),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
