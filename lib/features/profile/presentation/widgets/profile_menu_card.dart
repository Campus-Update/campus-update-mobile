import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class ProfileMenuItem {
  const ProfileMenuItem({
    required this.title,
    this.trailingIcon = Icons.chevron_right,
    this.onTap,
  });

  final String title;
  final IconData trailingIcon;
  final VoidCallback? onTap;
}

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({
    super.key,
    required this.items,
  });

  final List<ProfileMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFF3F4F6),
              ),
            _MenuRowItem(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _MenuRowItem extends StatelessWidget {
  const _MenuRowItem({required this.item});

  final ProfileMenuItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: AppFonts.family,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.graphite,
                  ),
                ),
              ),
              Icon(
                item.trailingIcon,
                size: 20,
                color: const Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
