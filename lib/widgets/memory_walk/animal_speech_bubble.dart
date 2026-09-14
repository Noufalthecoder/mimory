import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/core/theme/app_theme.dart';

/// Tiny hand-drawn storybook speech cloud floating above friendly animals.
/// Constrained to prevent any screen-edge or text overflow.
class AnimalSpeechBubbleWidget extends StatelessWidget {
  final String text;
  final double scale;

  const AnimalSpeechBubbleWidget({
    super.key,
    required this.text,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveScale = scale.clamp(0.65, 1.3);

    return Transform.scale(
      scale: effectiveScale,
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryPink.withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5A3E2B).withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    style: GoogleFonts.mali(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Tiny speech triangle pointing down to animal
              CustomPaint(
                size: const Size(10, 6),
                painter: _SpeechTrianglePainter(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeechTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.96)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppTheme.primaryPink.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.5, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawLine(Offset.zero, Offset(size.width * 0.5, size.height), borderPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width * 0.5, size.height), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
