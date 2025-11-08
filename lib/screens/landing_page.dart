import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LandingPage extends StatefulWidget {
  final VoidCallback onContinueAsVendor;
  final Future<void> Function() onContinueAsGuest;

  const LandingPage({
    super.key,
    required this.onContinueAsVendor,
    required this.onContinueAsGuest,
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _isLoadingGuest = false;

  Future<void> _handleGuestClick() async {
    setState(() {
      _isLoadingGuest = true;
    });
    try {
      await widget.onContinueAsGuest();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingGuest = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 400,
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/images/landing_image.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'AgroPine',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Smart Tools for Pineapple Farmers',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onContinueAsVendor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryYellow,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "I'm a Farmer / Vendor",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isLoadingGuest ? null : _handleGuestClick,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(
                          color: AppTheme.textDark,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoadingGuest
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Continue as Guest',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppTheme.textDark,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
