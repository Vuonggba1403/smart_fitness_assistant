import 'package:flutter/material.dart';

class BubbleTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3494E6)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(6, 0); // đỉnh trên (sát bubble)
    path.lineTo(0, 8); // mũi nhọn chĩa sang trái
    path.lineTo(6, 16); // đỉnh dưới
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
