import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../theme/app_theme.dart';

class BusinessCard extends StatelessWidget {
  final Map<String, dynamic> business;
  final bool compact;
  const BusinessCard({super.key, required this.business, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/businesses/${business['domain']}'),
      child: Container(
        width: compact ? 190 : double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _BusinessLogo(name: business['name'] ?? '', logoUrl: business['logo']),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(
                            business['name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (business['is_verified'] == true)
                          const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(Icons.verified, color: AppColors.primary, size: 16),
                          ),
                      ]),
                      const SizedBox(height: 2),
                      Text(
                        business['domain'] ?? '',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(children: [
              RatingBarIndicator(
                rating: (business['avg_ratings'] ?? 0.0).toDouble(),
                itemSize: 14,
                itemBuilder: (_, __) => const Icon(Icons.star, color: AppColors.starColor),
              ),
              const SizedBox(width: 6),
              Text(
                '${business['avg_ratings'] ?? 0} (${business['total_reviews'] ?? 0})',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ]),
            if (!compact && business['category'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  business['category'] is Map
                      ? (business['category']['name'] ?? '')
                      : business['category'].toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BusinessLogo extends StatefulWidget {
  final String name;
  final String? logoUrl;
  const _BusinessLogo({required this.name, this.logoUrl});

  @override
  State<_BusinessLogo> createState() => _BusinessLogoState();
}

class _BusinessLogoState extends State<_BusinessLogo> {
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    final initial = widget.name.isNotEmpty ? widget.name.substring(0, 1).toUpperCase() : 'B';

    if (_error || widget.logoUrl == null || widget.logoUrl!.isEmpty) {
      return _placeholder(initial);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        widget.logoUrl!,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _error = true);
          });
          return _placeholder(initial);
        },
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _placeholder(initial);
        },
      ),
    );
  }

  Widget _placeholder(String initial) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
