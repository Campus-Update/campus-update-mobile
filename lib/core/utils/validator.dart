import 'package:flutter_riverpod/flutter_riverpod.dart';

enum InputType { email, phoneNumber }

class Validators {
  // Regular expressions for email and phone validation
  static final _emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final _phoneRegex = RegExp(r'^\d{3}\d*$');

  // Property to store the type of the last validated input
  InputType? _lastValidatedType;

  // Getter to access the last validated input type
  InputType? get lastValidatedType => _lastValidatedType;

  bool isEmail(String input) {
    // Reset type if input is empty
    if (input.isEmpty) {
      _lastValidatedType = null;
      return false;
    }

    // If input has non-numeric character after first 3 digits or matches email regex, classify as email
    final isEmail = _emailRegex.hasMatch(input) ||
        (!_phoneRegex.hasMatch(input) && input.contains('@'));
    if (isEmail) {
      _lastValidatedType = InputType.email;
    }
    return isEmail;
  }

  bool isPhoneNumber(String input) {
    // Reset type if input is empty
    if (input.isEmpty) {
      _lastValidatedType = null;
      return false;
    }

    // If it starts with exactly 3 digits and continues as numbers, classify as phone
    final isPhone = _phoneRegex.hasMatch(input) && !input.contains('@');
    if (isPhone) {
      _lastValidatedType = InputType.phoneNumber;
    }
    return isPhone;
  }
}

final validatorsProvider = Provider<Validators>((ref) => Validators());