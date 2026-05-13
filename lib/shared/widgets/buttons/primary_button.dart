import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_shadows.dart';

class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? width;
  final double height;
  final Gradient? gradient;
  final EdgeInsets? padding;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = 56,
    this.gradient,
    this.padding,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  bool get _isInteractable => !widget.isDisabled && !widget.isLoading;

  void _onTapDown(TapDownDetails _) {
    if (_isInteractable) _scaleController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (_isInteractable) _scaleController.reverse();
  }

  void _onTapCancel() {
    if (_isInteractable) _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _isInteractable ? widget.onPressed : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: widget.isDisabled ? 0.5 : 1.0,
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height,
            padding: widget.padding,
            decoration: BoxDecoration(
              gradient: widget.isDisabled
                  ? null
                  : (widget.gradient ??
                  const LinearGradient(
                    colors: [
                      AppColors.primaryBlueMid,
                      AppColors.primaryBlue,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )),
              color: widget.isDisabled ? AppColors.border : null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: widget.isDisabled
                  ? null
                  : AppShadows.buttonShadow,
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                  AlwaysStoppedAnimation(AppColors.white),
                ),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.leadingIcon != null) ...[
                    Icon(widget.leadingIcon,
                        color: AppColors.white, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(widget.label, style: AppTypography.buttonL),
                  if (widget.trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(widget.trailingIcon,
                        color: AppColors.white, size: 18),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}