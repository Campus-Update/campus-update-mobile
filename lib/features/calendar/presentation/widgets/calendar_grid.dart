import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({
    super.key,
    required this.activeMonth,
    required this.selectedDate,
    required this.eventDays,
    required this.onDateSelected,
  });

  final DateTime activeMonth;
  final DateTime? selectedDate;
  final Set<int> eventDays;
  final ValueChanged<DateTime> onDateSelected;

  static const List<String> _weekdays = [
    'Su',
    'Mo',
    'Tu',
    'We',
    'Th',
    'Fr',
    'Sa',
  ];

  @override
  Widget build(BuildContext context) {
    final year = activeMonth.year;
    final month = activeMonth.month;

    // Sunday = 0, Monday = 1, ..., Saturday = 6
    final firstWeekday = DateTime(year, month, 1).weekday % 7;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final totalCells = firstWeekday + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Column(
      children: [
        // Weekday Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _weekdays.map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: AppFonts.regular,
                    color: AppColors.sourceSponsored,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // Calendar Days Grid
        for (int row = 0; row < rowCount; row++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (col) {
                final cellIndex = row * 7 + col;

                // Leading empty cells before the 1st of the month
                if (cellIndex < firstWeekday) {
                  return const Expanded(child: SizedBox(height: 38));
                }

                final dayNumber = cellIndex - firstWeekday + 1;

                // Trailing days from the next month
                if (dayNumber > daysInMonth) {
                  final nextMonthDay = dayNumber - daysInMonth;
                  return Expanded(
                    child: Center(
                      child: Text(
                        '$nextMonthDay',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: AppFonts.regular,
                          color: AppColors.fieldHintDot,
                        ),
                      ),
                    ),
                  );
                }

                final date = DateTime(year, month, dayNumber);
                final isSelected =
                    selectedDate != null &&
                    selectedDate!.year == year &&
                    selectedDate!.month == month &&
                    selectedDate!.day == dayNumber;
                final hasEvent = eventDays.contains(dayNumber);

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onDateSelected(date),
                    child: Center(
                      child: _buildDayCell(
                        day: dayNumber,
                        isSelected: isSelected,
                        hasEvent: hasEvent,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDayCell({
    required int day,
    required bool isSelected,
    required bool hasEvent,
  }) {
    if (isSelected) {
      return Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.indigo,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: AppFonts.medium,
            color: Colors.white,
          ),
        ),
      );
    }

    if (hasEvent) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.indigoSurface,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: AppFonts.medium,
            color: AppColors.indigo,
          ),
        ),
      );
    }

    return SizedBox(
      width: 36,
      height: 36,
      child: Center(
        child: Text(
          '$day',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: AppFonts.regular,
            color: AppColors.graphite,
          ),
        ),
      ),
    );
  }
}
