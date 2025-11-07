class FormValidationState {
  final bool isFirstNameValid;
  final bool isLastNameValid;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isPasswordConfirmedValid;
  final bool isBusinessNumberValid;
  final bool isAgreedToTerms;

  FormValidationState({
    required this.isFirstNameValid,
    required this.isLastNameValid,
    required this.isEmailValid,
    required this.isPasswordValid,
    required this.isPasswordConfirmedValid,
    required this.isBusinessNumberValid,
    required this.isAgreedToTerms,
  });

  bool get isFormValid {
    return isFirstNameValid &&
        isLastNameValid &&
        isEmailValid &&
        isPasswordValid &&
        isPasswordConfirmedValid &&
        isBusinessNumberValid &&
        isAgreedToTerms;
  }
}

class LoginFormValidationState {
  final bool isEmailValid;
  final bool isPasswordValid;

  LoginFormValidationState({
    required this.isEmailValid,
    required this.isPasswordValid,
  });

  bool get isFormValid => isEmailValid && isPasswordValid;
}

class ForgotPasswordFormValidationState {
  final bool isEmailValid;

  ForgotPasswordFormValidationState({
    required this.isEmailValid,
  });

  bool get isFormValid => isEmailValid;
}
