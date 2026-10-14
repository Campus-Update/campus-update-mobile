import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// The search bar shown below the header in Active Alerts when search is active.
///
/// Features:
/// - Clean back arrow button
/// - Rounded rectangle search input (subtle radius ~14px, #F7F7F8 background)
/// - Magnifying glass icon, indigo cursor, graphite text
/// - Circular clear button (#E5E7EB ground with dark grey #6B7280 'x')
/// - Brand indigo "Cancel" button
class AlertsSearchBar extends StatelessWidget {
  const AlertsSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onCancel,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back arrow.
          GestureDetector(
            onTap: onCancel,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Icon(Icons.arrow_back, size: 22, color: Color(0xFF1F2937)),
            ),
          ),
          const SizedBox(width: 10),

          // Search input field.
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F8),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.search, size: 20, color: Color(0xFF6B7280)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: onChanged,
                      cursorColor: AppColors.indigo,
                      cursorWidth: 2.0,
                      style: const TextStyle(
                        fontFamily: AppFonts.family,
                        fontSize: 15,
                        fontWeight: AppFonts.regular,
                        color: Color(0xFF1F2937),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search by title, or keywords',
                        hintStyle: TextStyle(
                          fontFamily: AppFonts.family,
                          fontSize: 15,
                          fontWeight: AppFonts.regular,
                          color: Color(0xFF9CA3AF),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        controller.clear();
                        onChanged('');
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE5E7EB),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.close,
                            size: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Cancel text button.
          GestureDetector(
            onTap: onCancel,
            behavior: HitTestBehavior.opaque,
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: AppFonts.family,
                color: AppColors.indigo,
                fontWeight: AppFonts.medium,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
