import 'package:gym_management_app/core/utils/phone_normalizer.dart';

/// Form validation helpers returning an error message or `null` when valid.
abstract final class Validators {
  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _phonePattern = RegExp(r'^\+?\d{7,15}$');

  static String? required(
    String? value, {
    String message = 'This field is required.',
  }) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value);
    if (requiredError != null) {
      return requiredError;
    }
    if (!_emailPattern.hasMatch(value!.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? password(
    String? value, {
    int minLength = 8,
    String message = 'Password must be at least 8 characters.',
  }) {
    final requiredError = required(value);
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.length < minLength) {
      return message;
    }
    return null;
  }

  /// Validates a phone number after normalization. Accepts 7–15 digits with
  /// an optional leading `+` (country code marker).
  static String? phone(
    String? value, {
    String message = 'Enter a valid phone number.',
  }) {
    final requiredError = required(value);
    if (requiredError != null) {
      return requiredError;
    }
    if (!_phonePattern.hasMatch(PhoneNormalizer.normalize(value))) {
      return message;
    }
    return null;
  }
}
