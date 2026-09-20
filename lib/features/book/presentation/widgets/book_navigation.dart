import 'package:flutter/material.dart';

class BookNavigation extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const BookNavigation({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NavButton(
            icon: Icons.arrow_back,
            onPressed: currentPage > 1 ? onPrevious : null,
          ),
          const SizedBox(width: 24),
          Text(
            '${currentPage.toString().padLeft(2, '0')} / ${totalPages.toString().padLeft(2, '0')}',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary.withOpacity(0.6),
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(width: 24),
          _NavButton(
            icon: Icons.arrow_forward,
            onPressed: currentPage < totalPages ? onNext : null,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _NavButton({
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isEnabled 
                  ? colorScheme.primary.withOpacity(0.1) 
                  : Colors.transparent,
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isEnabled 
                ? colorScheme.primary 
                : colorScheme.primary.withOpacity(0.2),
          ),
        ),
      ),
    );
  }
}
