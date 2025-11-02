import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/input_validators.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final strength = InputValidators.checkPasswordStrength(password);
    
    if (strength == PasswordStrength.empty) {
      return const SizedBox.shrink();
    }

    Color strengthColor;
    switch (strength) {
      case PasswordStrength.weak:
        strengthColor = AppTheme.errorRed;
      case PasswordStrength.medium:
        strengthColor = AppTheme.primaryYellow;
      case PasswordStrength.strong:
        strengthColor = AppTheme.lightGreen;
      case PasswordStrength.empty:
        strengthColor = AppTheme.borderColor;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: strength.strength_percent / 100,
                  minHeight: 4,
                  backgroundColor: AppTheme.borderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strength.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: strengthColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
