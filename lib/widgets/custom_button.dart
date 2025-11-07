import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double width;
  final EdgeInsets padding;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width = double.infinity,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: (isLoading || !isEnabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: padding,
          backgroundColor: isEnabled ? AppTheme.primaryGold : Colors.grey[300],
          foregroundColor: isEnabled ? AppTheme.textDark : Colors.grey[600],
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[600],
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isEnabled ? AppTheme.textDark : Colors.grey[600]!,
                  ),
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isEnabled ? AppTheme.textDark : Colors.grey[600],
                ),
              ),
      ),
    );
  }
}
