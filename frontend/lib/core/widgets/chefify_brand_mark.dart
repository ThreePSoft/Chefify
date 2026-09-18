import 'package:flutter/material.dart';

class ChefifyBrandMark extends StatelessWidget {
  const ChefifyBrandMark({super.key, this.size = 42, this.borderRadius = 14});

  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE08A57), Color(0xFFB85C38)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: const CustomPaint(painter: _ChefifyHatPainter()),
        ),
      ),
    );
  }
}

class _ChefifyHatPainter extends CustomPainter {
  const _ChefifyHatPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = const Color(0xFFFFFDF9);
    final slot = Paint()..color = const Color(0xFFC96B3B);
    final unit = size.shortestSide;

    canvas
      ..drawCircle(Offset(unit * 0.34, unit * 0.43), unit * 0.16, white)
      ..drawCircle(Offset(unit * 0.5, unit * 0.32), unit * 0.2, white)
      ..drawCircle(Offset(unit * 0.66, unit * 0.43), unit * 0.16, white)
      ..drawRect(
        Rect.fromLTWH(unit * 0.25, unit * 0.42, unit * 0.5, unit * 0.24),
        white,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(unit * 0.29, unit * 0.61, unit * 0.42, unit * 0.2),
          Radius.circular(unit * 0.055),
        ),
        white,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(unit * 0.39, unit * 0.66, unit * 0.055, unit * 0.1),
          Radius.circular(unit * 0.018),
        ),
        slot,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(unit * 0.555, unit * 0.66, unit * 0.055, unit * 0.1),
          Radius.circular(unit * 0.018),
        ),
        slot,
      );
  }

  @override
  bool shouldRepaint(covariant _ChefifyHatPainter oldDelegate) => false;
}
