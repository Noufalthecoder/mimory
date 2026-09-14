import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mimory/core/theme/app_theme.dart';

/// A soft, minimalist, storybook joystick for controlling the couple in Memory Walk mode.
/// Non-intrusive, low visual weight, translucent cream with a pastel pink thumb stick.
class MemoryWalkJoystick extends StatefulWidget {
  final Function(Offset direction, bool isMoving) onDirectionChanged;
  final double size;
  final double touchPadding;

  const MemoryWalkJoystick({
    super.key,
    required this.onDirectionChanged,
    this.size = 88.0,
    this.touchPadding = 20.0,
  });

  @override
  State<MemoryWalkJoystick> createState() => _MemoryWalkJoystickState();
}

class _MemoryWalkJoystickState extends State<MemoryWalkJoystick> {
  Offset _thumbOffset = Offset.zero;
  bool _isInteracting = false;

  double get _maxRadius => (widget.size / 2) - 16;
  double get _totalTouchSize => widget.size + widget.touchPadding * 2;

  void _updatePosition(Offset localPos) {
    final center = Offset(_totalTouchSize / 2, _totalTouchSize / 2);
    final delta = localPos - center;
    final distance = delta.distance;

    if (distance <= _maxRadius) {
      _thumbOffset = delta;
    } else {
      final angle = math.atan2(delta.dy, delta.dx);
      _thumbOffset = Offset(
        math.cos(angle) * _maxRadius,
        math.sin(angle) * _maxRadius,
      );
    }

    final normalized = Offset(
      (_thumbOffset.dx / _maxRadius).clamp(-1.0, 1.0),
      (_thumbOffset.dy / _maxRadius).clamp(-1.0, 1.0),
    );

    // Smooth proportional deadzone of 0.10 for comfortable stillness
    if (normalized.distance > 0.10) {
      widget.onDirectionChanged(normalized, true);
    } else {
      widget.onDirectionChanged(Offset.zero, false);
    }

    setState(() {});
  }

  void _resetPosition() {
    setState(() {
      _thumbOffset = Offset.zero;
      _isInteracting = false;
    });
    widget.onDirectionChanged(Offset.zero, false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) {
        _isInteracting = true;
        _updatePosition(details.localPosition);
      },
      onPanUpdate: (details) {
        _updatePosition(details.localPosition);
      },
      onPanEnd: (_) => _resetPosition(),
      onPanCancel: () => _resetPosition(),
      child: Container(
        width: _totalTouchSize,
        height: _totalTouchSize,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Container(
          width: widget.size,
          height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: _isInteracting ? 0.85 : 0.65),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.95),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5A3E2B).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Subtle directional guides
              CustomPaint(
                size: Size(widget.size * 0.7, widget.size * 0.7),
                painter: _JoystickGuidePainter(),
              ),

              // Floating Thumb Stick
              Transform.translate(
                offset: _thumbOffset,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryPink,
                        AppTheme.primaryPink.withValues(alpha: 0.85),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPink.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _JoystickGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = const Color(0xFFB0A499).withValues(alpha: 0.25)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Subtle 4-way dots
    canvas.drawCircle(Offset(center.dx, center.dy - r), 2, guidePaint);
    canvas.drawCircle(Offset(center.dx, center.dy + r), 2, guidePaint);
    canvas.drawCircle(Offset(center.dx - r, center.dy), 2, guidePaint);
    canvas.drawCircle(Offset(center.dx + r, center.dy), 2, guidePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
