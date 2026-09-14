import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/features/monetization/widgets/storybook_decorations.dart';
import 'package:mimory/core/widgets/tactile_pill_button.dart';
import 'package:mimory/features/world/screens/create_world_screen.dart';

class RelationshipSelectionScreen extends StatefulWidget {
  const RelationshipSelectionScreen({super.key});

  @override
  State<RelationshipSelectionScreen> createState() =>
      _RelationshipSelectionScreenState();
}

class _RelationshipSelectionScreenState
    extends State<RelationshipSelectionScreen> {
  String? _selectedOption;

  final List<Map<String, dynamic>> _options = [
    {
      'id': 'partner',
      'label': 'Partner',
      'subtitle': 'A world for two souls in love.',
      'bgColor': AppTheme.primaryPinkLight,
    },
    {
      'id': 'best_friend',
      'label': 'Best Friend',
      'subtitle': 'Shared laughter, stories, and journeys.',
      'bgColor': AppTheme.sageGreenLight,
    },
    {
      'id': 'family',
      'label': 'Family',
      'subtitle': 'Warm roots and unforgettable bonds.',
      'bgColor': AppTheme.softPeachLight,
    },
    {
      'id': 'friend_group',
      'label': 'Friend Group',
      'subtitle': 'Your little circle of favorite people.',
      'bgColor': AppTheme.softYellow,
    },
    {
      'id': 'custom',
      'label': 'Custom',
      'subtitle': 'A unique world crafted just for you.',
      'bgColor': AppTheme.mutedLavender,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.creamLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.borderSubtle,
                      width: 1,
                    ),
                    boxShadow: AppTheme.paperShadow,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppTheme.textPrimary,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Center(
                child: Text(
                  'Who do you want\nto create a world with?',
                  style: GoogleFonts.mali(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    height: 1.25,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Center(
                child: Text(
                  'Choose the people who make your memories special.',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 28),

              // Options List
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _options.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final option = _options[index];
                    final isSelected = _selectedOption == option['id'];

                    return _buildRelationshipCard(
                      id: option['id'],
                      label: option['label'],
                      subtitle: option['subtitle'],
                      bgColor: option['bgColor'],
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedOption = option['id'];
                        });
                      },
                    );
                  },
                ),
              ),

              // Next Tactile Pill Button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TactilePillButton(
                  onPressed: _selectedOption != null
                      ? () {
                          final selectedLabel = _options.firstWhere(
                              (o) => o['id'] == _selectedOption)['label'];
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      CreateWorldScreen(
                                relationshipId: _selectedOption!,
                                relationshipLabel: selectedLabel,
                              ),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                    opacity: animation, child: child);
                              },
                              transitionDuration:
                                  const Duration(milliseconds: 350),
                            ),
                          );
                        }
                      : null,
                  text: 'Continue ♡',
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelationshipCard({
    required String id,
    required String label,
    required String subtitle,
    required Color bgColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Transform.scale(
      scale: isSelected ? 1.025 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.creamLight : AppTheme.creamLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? AppTheme.primaryPink : AppTheme.borderSubtle,
              width: isSelected ? 2.0 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryPink.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                    ...AppTheme.paperShadow,
                  ]
                : AppTheme.paperShadow,
          ),
          child: Row(
            children: [
              // Custom Illustrated Motif container
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: _buildIllustratedIcon(id, isSelected),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.mali(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppTheme.textPrimary
                                : AppTheme.textPrimary,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          const StorybookSparkle(size: 13),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppTheme.primaryPink
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryPink
                        : AppTheme.borderSubtle,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Custom hand-drawn vector illustrations for each relationship type (no generic emojis!)
  Widget _buildIllustratedIcon(String id, bool isSelected) {
    switch (id) {
      case 'partner':
        return CustomPaint(
          size: const Size(32, 32),
          painter: _PartnerIllustrationPainter(isSelected: isSelected),
        );
      case 'best_friend':
        return CustomPaint(
          size: const Size(32, 32),
          painter: _BestFriendIllustrationPainter(isSelected: isSelected),
        );
      case 'family':
        return CustomPaint(
          size: const Size(32, 32),
          painter: _FamilyIllustrationPainter(isSelected: isSelected),
        );
      case 'friend_group':
        return CustomPaint(
          size: const Size(32, 32),
          painter: _FriendGroupIllustrationPainter(isSelected: isSelected),
        );
      case 'custom':
      default:
        return CustomPaint(
          size: const Size(32, 32),
          painter: _CustomIllustrationPainter(isSelected: isSelected),
        );
    }
  }
}

/// Partner: Two cute character silhouettes with a tiny floating heart
class _PartnerIllustrationPainter extends CustomPainter {
  final bool isSelected;
  _PartnerIllustrationPainter({required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final headPaint1 = Paint()..color = AppTheme.primaryPink;
    final headPaint2 = Paint()..color = const Color(0xFF7AA880);

    // Left character
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.55), 6.5, headPaint1);
    // Right character
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.55), 6.5, headPaint2);

    // Tiny heart floating above
    final heartPaint = Paint()..color = AppTheme.primaryPinkDark;
    final hx = size.width * 0.5;
    final hy = size.height * 0.28;
    canvas.drawCircle(Offset(hx - 2.2, hy), 2.8, heartPaint);
    canvas.drawCircle(Offset(hx + 2.2, hy), 2.8, heartPaint);

    final path = Path();
    path.moveTo(hx - 4.5, hy + 1);
    path.lineTo(hx, hy + 5.5);
    path.lineTo(hx + 4.5, hy + 1);
    path.close();
    canvas.drawPath(path, heartPaint);
  }

  @override
  bool shouldRepaint(covariant _PartnerIllustrationPainter oldDelegate) =>
      oldDelegate.isSelected != isSelected;
}

/// Best Friend: Two friends side-by-side with a tiny sprout
class _BestFriendIllustrationPainter extends CustomPainter {
  final bool isSelected;
  _BestFriendIllustrationPainter({required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final friendPaint = Paint()..color = AppTheme.sageGreen;
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.58), 6.5, friendPaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.58), 6.5, friendPaint);

    // Tiny sprout
    final sproutPaint = Paint()
      ..color = AppTheme.sageGreen
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.45),
      Offset(size.width * 0.5, size.height * 0.25),
      sproutPaint,
    );
    final leafPaint = Paint()..color = AppTheme.sageGreen;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.42, size.height * 0.26),
        width: 5,
        height: 3,
      ),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.58, size.height * 0.26),
        width: 5,
        height: 3,
      ),
      leafPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BestFriendIllustrationPainter oldDelegate) =>
      oldDelegate.isSelected != isSelected;
}

/// Family: Small family cluster with cozy house roof line
class _FamilyIllustrationPainter extends CustomPainter {
  final bool isSelected;
  _FamilyIllustrationPainter({required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    // Roof line
    final roofPaint = Paint()
      ..color = AppTheme.softPeach
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.40);
    path.lineTo(size.width * 0.5, size.height * 0.20);
    path.lineTo(size.width * 0.8, size.height * 0.40);
    canvas.drawPath(path, roofPaint);

    // Parent & Child heads
    final p1 = Paint()..color = const Color(0xFFC49A7E);
    canvas.drawCircle(Offset(size.width * 0.34, size.height * 0.62), 6.0, p1);
    canvas.drawCircle(Offset(size.width * 0.66, size.height * 0.62), 6.0, p1);
    canvas.drawCircle(Offset(size.width * 0.50, size.height * 0.68), 4.5, Paint()..color = AppTheme.primaryPink);
  }

  @override
  bool shouldRepaint(covariant _FamilyIllustrationPainter oldDelegate) =>
      oldDelegate.isSelected != isSelected;
}

/// Friend Group: 3-4 tiny circle friends grouped together
class _FriendGroupIllustrationPainter extends CustomPainter {
  final bool isSelected;
  _FriendGroupIllustrationPainter({required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      AppTheme.primaryPink,
      AppTheme.sageGreen,
      const Color(0xFFE5B068),
      const Color(0xFF9D8DF1),
    ];

    canvas.drawCircle(Offset(size.width * 0.32, size.height * 0.42), 5.5, Paint()..color = colors[0]);
    canvas.drawCircle(Offset(size.width * 0.68, size.height * 0.42), 5.5, Paint()..color = colors[1]);
    canvas.drawCircle(Offset(size.width * 0.40, size.height * 0.68), 5.5, Paint()..color = colors[2]);
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.68), 5.5, Paint()..color = colors[3]);
  }

  @override
  bool shouldRepaint(covariant _FriendGroupIllustrationPainter oldDelegate) =>
      oldDelegate.isSelected != isSelected;
}

/// Custom: A little storybook door with warm star light
class _CustomIllustrationPainter extends CustomPainter {
  final bool isSelected;
  _CustomIllustrationPainter({required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()..color = const Color(0xFFE2B755);
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;

    final path = Path();
    path.moveTo(cx, cy - 10);
    path.quadraticBezierTo(cx, cy, cx + 10, cy);
    path.quadraticBezierTo(cx, cy, cx, cy + 10);
    path.quadraticBezierTo(cx, cy, cx - 10, cy);
    path.quadraticBezierTo(cx, cy, cx, cy - 10);
    path.close();
    canvas.drawPath(path, starPaint);
    canvas.drawCircle(Offset(cx, cy), 3.0, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _CustomIllustrationPainter oldDelegate) =>
      oldDelegate.isSelected != isSelected;
}
