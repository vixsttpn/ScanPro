
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ScanOverlay extends StatelessWidget {
  final Widget child;
  const ScanOverlay({super.key, required this.child});
  @override Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(child: child),
      Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _DimPainter()))),
    ]);
  }
}
class _DimPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(size.width*0.08, size.height*0.18, size.width*0.84, size.height*0.55);
    final path = Path()..addRect(Rect.fromLTWH(0,0,size.width,size.height))..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)))..fillType=PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color=Colors.black.withOpacity(0.9));
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)), Paint()..color=Colors.white.withOpacity(0.08)..style=PaintingStyle.stroke..strokeWidth=1);
  }
  @override bool shouldRepaint(covariant CustomPainter old)=>false;
}
