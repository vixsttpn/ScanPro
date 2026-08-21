
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/doc_processor.dart';

class EdgePainter extends CustomPainter {
  final List<DocPoints>? points;
  final Size imageSize;
  final bool stable;
  EdgePainter({this.points, required this.imageSize, this.stable=false});

  @override
  void paint(Canvas canvas, Size size) {
    if (points==null || points!.length!=4) return;
    final paint = Paint()
      ..color = stable? Colors.white : AppColors.text
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final glow = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final path = Path()
      ..moveTo(points![0].x*size.width, points![0].y*size.height)
      ..lineTo(points![1].x*size.width, points![1].y*size.height)
      ..lineTo(points![2].x*size.width, points![2].y*size.height)
      ..lineTo(points![3].x*size.width, points![3].y*size.height)
      ..close();
    canvas.drawPath(path, glow);
    canvas.drawPath(path, paint);
    // corner dots draggable
    final dotPaint = Paint()..color = AppColors.text..style=PaintingStyle.fill;
    final dotBorder = Paint()..color = AppColors.bg..strokeWidth=2..style=PaintingStyle.stroke;
    for (var p in points!) {
      final offset = Offset(p.x*size.width, p.y*size.height);
      canvas.drawCircle(offset, 12, dotBorder);
      canvas.drawCircle(offset, 9, dotPaint);
      canvas.drawCircle(offset, 3, Paint()..color=AppColors.bg);
    }
  }
  @override bool shouldRepaint(covariant EdgePainter old)=> old.points!=points || old.stable!=stable;
}
