part of '../pages/recipe_create_page.dart';

class _RecipeDividerPreview extends StatelessWidget {
  const _RecipeDividerPreview({
    required this.style,
    required this.thickness,
    required this.color,
  });

  final _RecipeDividerStyle style;
  final _RecipeDividerThickness thickness;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('recipe-divider-preview'),
      height: 28,
      width: double.infinity,
      child: CustomPaint(
        painter: _RecipeDividerPainter(
          style: style,
          thickness: thickness,
          color: color,
        ),
      ),
    );
  }
}

class _RecipeDividerPainter extends CustomPainter {
  const _RecipeDividerPainter({
    required this.style,
    required this.thickness,
    required this.color,
  });

  final _RecipeDividerStyle style;
  final _RecipeDividerThickness thickness;
  final Color color;

  double get strokeWidth => switch (thickness) {
    _RecipeDividerThickness.thin => 1,
    _RecipeDividerThickness.regular => 2,
    _RecipeDividerThickness.bold => 4,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    switch (style) {
      case _RecipeDividerStyle.solid:
        canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), paint);
        break;
      case _RecipeDividerStyle.dotted:
        final spacing = math.max(5.0, strokeWidth * 3);
        for (var x = strokeWidth; x < size.width; x += spacing) {
          canvas.drawCircle(Offset(x, centerY), strokeWidth / 1.5, paint);
        }
        break;
      case _RecipeDividerStyle.dashed:
        _drawPattern(canvas, size.width, centerY, paint, const [12, 7]);
        break;
      case _RecipeDividerStyle.dashDot:
        _drawPattern(canvas, size.width, centerY, paint, const [14, 6, 2, 6]);
        break;
      case _RecipeDividerStyle.doubleLine:
        final offset = strokeWidth + 2;
        canvas
          ..drawLine(
            Offset(0, centerY - offset),
            Offset(size.width, centerY - offset),
            paint,
          )
          ..drawLine(
            Offset(0, centerY + offset),
            Offset(size.width, centerY + offset),
            paint,
          );
        break;
    }
  }

  void _drawPattern(
    Canvas canvas,
    double width,
    double y,
    Paint paint,
    List<double> pattern,
  ) {
    var x = 0.0;
    var patternIndex = 0;
    var drawing = true;
    while (x < width) {
      final segment = pattern[patternIndex % pattern.length];
      final end = math.min(width, x + segment);
      if (drawing) {
        canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      }
      x = end;
      patternIndex += 1;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(covariant _RecipeDividerPainter oldDelegate) {
    return oldDelegate.style != style ||
        oldDelegate.thickness != thickness ||
        oldDelegate.color != color;
  }
}

class _RecipeBlockResizeHandle extends StatefulWidget {
  const _RecipeBlockResizeHandle({
    required this.blockId,
    required this.onResizeStart,
    required this.onResize,
    required this.onResizeEnd,
  });

  final String blockId;
  final VoidCallback onResizeStart;
  final ValueChanged<double> onResize;
  final VoidCallback onResizeEnd;

  @override
  State<_RecipeBlockResizeHandle> createState() =>
      _RecipeBlockResizeHandleState();
}

class _RecipeBlockResizeHandleState extends State<_RecipeBlockResizeHandle> {
  bool _hovered = false;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final active = _hovered || _dragging;

    return MouseRegion(
      key: ValueKey('recipe-editor-block-resize-${widget.blockId}'),
      cursor: SystemMouseCursors.resizeUpDown,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.down,
        onVerticalDragStart: (_) {
          setState(() => _dragging = true);
          widget.onResizeStart();
        },
        onVerticalDragUpdate: (details) => widget.onResize(details.delta.dy),
        onVerticalDragEnd: (_) => _finishDrag(),
        onVerticalDragCancel: _finishDrag,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            width: active ? 72 : 42,
            height: 2,
            color: palette.primaryButtons.withValues(alpha: active ? 0.72 : 0),
          ),
        ),
      ),
    );
  }

  void _finishDrag() {
    if (_dragging) {
      setState(() => _dragging = false);
    }
    widget.onResizeEnd();
  }
}

class _RecipeBlockEdgeBorderPainter extends CustomPainter {
  const _RecipeBlockEdgeBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.18),
          color,
          color.withValues(alpha: 0.18),
        ],
      ).createShader(Offset.zero & size);
    final halfWidth = size.width / 2;

    final topPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 0.55)
      ..quadraticBezierTo(halfWidth, 3.1, 0, 0.55)
      ..close();
    final bottomPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height - 0.55)
      ..quadraticBezierTo(halfWidth, size.height - 3.1, 0, size.height - 0.55)
      ..close();

    canvas
      ..drawPath(topPath, paint)
      ..drawPath(bottomPath, paint);
  }

  @override
  bool shouldRepaint(covariant _RecipeBlockEdgeBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
