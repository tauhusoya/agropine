import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool isHero;
  final String tag;

  const AppLogo({
    super.key,
    this.size = 80,
    this.isHero = false,
    this.tag = 'app_logo',
  });

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGold.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: Image.asset(
            'assets/images/logo.png',
            width: size * 0.9,
            height: size * 0.9,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );

    if (isHero) {
      return Hero(
        tag: tag,
        child: logo,
      );
    }

    return logo;
  }
}
