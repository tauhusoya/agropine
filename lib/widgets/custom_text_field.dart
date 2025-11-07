import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final bool isPassword;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final bool enabled;
  final String? helperText;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
    this.isPassword = false,
    this.maxLines = 1,
    this.onChanged,
    this.readOnly = false,
    this.enabled = true,
    this.helperText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  String? _errorText;
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    widget.controller.addListener(_validateField);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateField);
    super.dispose();
  }

  void _validateField() {
    if (_touched && widget.validator != null) {
      final error = widget.validator!(widget.controller.text);
      setState(() {
        _errorText = error;
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        // Input Field
        TextField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          readOnly: widget.readOnly || !widget.enabled,
          enabled: widget.enabled,
          onChanged: (value) {
            _validateField();
            widget.onChanged?.call(value);
          },
          onTap: () {
            setState(() {
              _touched = true;
            });
            _validateField();
          },
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: widget.enabled ? _togglePasswordVisibility : null,
                  )
                : null,
            errorText: _touched ? _errorText : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _touched && _errorText != null
                    ? AppTheme.errorRed
                    : AppTheme.borderColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _touched && _errorText != null
                    ? AppTheme.errorRed
                    : AppTheme.borderColor,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.borderColor.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _touched && _errorText != null
                    ? AppTheme.errorRed
                    : AppTheme.primaryGold,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.errorRed,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.errorRed,
                width: 2,
              ),
            ),
          ),
        ),
        // Error message (removed to avoid duplicate error display)
        // if (_touched && _errorText != null)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 6),
        //     child: Row(
        //       children: [
        //         const Icon(
        //           Icons.error_outline,
        //           size: 16,
        //           color: AppTheme.errorRed,
        //         ),
        //         const SizedBox(width: 6),
        //         Expanded(
        //           child: Text(
        //             _errorText!,
        //             style: Theme.of(context).textTheme.bodySmall?.copyWith(
        //                   color: AppTheme.errorRed,
        //                   fontWeight: FontWeight.w500,
        //                 ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
      ],
    );
  }
}
