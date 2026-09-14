import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/core/theme/app_theme.dart';

class TactilePillButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String? text;
  final Widget? child;
  final Widget? leading;
  final Widget? trailing;
  final Color backgroundColor;
  final Color foregroundColor;
  final double height;
  final double? width;
  final EdgeInsetsGeometry padding;
  final bool isSecondary;
  final Border? border;

  const TactilePillButton({
    super.key,
    required this.onPressed,
    this.text,
    this.child,
    this.leading,
    this.trailing,
    this.backgroundColor = AppTheme.primaryPink,
    this.foregroundColor = Colors.white,
    this.height = 56,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
    this.isSecondary = false,
    this.border,
  }) : assert(text != null || child != null, 'Either text or child must be provided');

  @override
  State<TactilePillButton> createState() => _TactilePillButtonState();
}

class _TactilePillButtonState extends State<TactilePillButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    _controller.reverse().then((_) {
      if (mounted) setState(() => _isPressed = false);
    });
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    if (widget.onPressed == null) return;
    _controller.reverse().then((_) {
      if (mounted) setState(() => _isPressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBg = widget.isSecondary
        ? AppTheme.creamLight
        : widget.backgroundColor;
    final effectiveFg = widget.isSecondary
        ? AppTheme.textPrimary
        : widget.foregroundColor;
    final isEnabled = widget.onPressed != null;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: isEnabled
                ? (_isPressed
                    ? (widget.isSecondary
                        ? AppTheme.creamDark
                        : AppTheme.primaryPinkDark)
                    : effectiveBg)
                : AppTheme.creamDark.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(30),
            border: widget.border ??
                (widget.isSecondary
                    ? Border.all(
                        color: AppTheme.borderSubtle,
                        width: 1.5,
                      )
                    : Border.all(
                        color: Colors.white,
                        width: 2.0,
                      )),
            boxShadow: isEnabled && !_isPressed
                ? (widget.isSecondary
                    ? AppTheme.paperShadow
                    : AppTheme.buttonShadow)
                : const [],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 8),
                ],
                if (widget.child != null)
                  Flexible(child: widget.child!)
                else
                  Flexible(
                    child: Text(
                      widget.text!,
                      style: GoogleFonts.nunito(
                        color: isEnabled
                            ? effectiveFg
                            : AppTheme.textTertiary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: 8),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
