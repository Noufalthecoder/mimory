import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/models/memory.dart';
import 'package:mimory/core/theme/app_theme.dart';

class MemoryCard extends StatelessWidget {
  final Memory memory;
  final VoidCallback? onTap;

  const MemoryCard({super.key, required this.memory, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPhoto = memory.type == MemoryType.photo;
    final accentColor = isPhoto ? AppTheme.primaryPink : AppTheme.sageGreen;
    final accentLight = isPhoto ? AppTheme.primaryPinkLight : AppTheme.sageGreenLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.creamLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.borderSubtle,
          width: 1.2,
        ),
        boxShadow: AppTheme.paperShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accentLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPhoto ? Icons.photo_outlined : Icons.menu_book_rounded,
                            color: accentColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatDate(memory.memoryDate),
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.more_horiz,
                      color: AppTheme.textTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  memory.title,
                  style: GoogleFonts.mali(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (memory.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    memory.description,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                      height: 1.45,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String hour = date.hour > 12 ? (date.hour - 12).toString() : date.hour.toString();
    if (hour == '0') hour = '12';
    String minute = date.minute.toString().padLeft(2, '0');
    String ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day}, $hour:$minute $ampm';
  }
}
