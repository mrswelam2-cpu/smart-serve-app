import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../theme/app_theme.dart';

class CraftsmanCard extends StatelessWidget {
  final Map<String, dynamic> craftsman;
  final bool compact;
  const CraftsmanCard({super.key, required this.craftsman, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/craftsmen/${craftsman['username']}'),
      child: Container(
        width: compact ? 160 : double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(compact ? 24 : 14),
                  child: CachedNetworkImage(
                    imageUrl: craftsman['avatar'] ?? '',
                    width: compact ? 48 : 52,
                    height: compact ? 48 : 52,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => CircleAvatar(
                      radius: compact ? 24 : 26,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        (craftsman['name'] ?? 'C').substring(0, 1),
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(craftsman['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(craftsman['profession'] ?? '',
                          style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(children: [
              RatingBarIndicator(
                rating: (craftsman['avg_ratings'] ?? 0.0).toDouble(),
                itemSize: 14,
                itemBuilder: (_, __) => const Icon(Icons.star, color: AppColors.starColor),
              ),
              const SizedBox(width: 6),
              Text('${craftsman['avg_ratings'] ?? 0} (${craftsman['total_reviews'] ?? 0})',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ]),
            if (!compact && craftsman['city'] != null) ...[
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(craftsman['city'], style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
