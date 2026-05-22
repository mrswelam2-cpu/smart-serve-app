import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  const SectionHeader({super.key, required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Row(children: [
                Text('عرض الكل', style: TextStyle(fontSize: 13)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 12),
              ]),
            ),
        ],
      ),
    );
  }
}
