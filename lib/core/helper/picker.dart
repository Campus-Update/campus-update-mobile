import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/translator.dart';
import '../utils/toast.dart';

class Picker {
  static Future<DateTime?> showDatePickerDialog({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );
  }

  static Future<TimeOfDay?> showTimePickerDialog({
    required BuildContext context,
    TimeOfDay? initialTime,
  }) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
  }

  static Future<Either<String, dynamic>> pickImage({
    required BuildContext context,
    required ImageSource source,
    // bool? multiple,
  }) async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      return right(File(image.path));
    }

    ToastHelper.showToast(context, translate("noPicPicked"), Colors.black54);
    return left("No picture picked");
  }
}