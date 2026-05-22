import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.getCategories();
      setState(() { _categories = res['data']; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التصنيفات')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                return GestureDetector(
                  onTap: () => context.push('/businesses?category=${cat['slug']}'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              _getCategoryIcon(i),
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(cat['name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('${cat['businesses_count'] ?? 0} عمل',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  IconData _getCategoryIcon(int index) {
    const icons = [
      Icons.business_center_outlined,
      Icons.favorite_outline,
      Icons.devices_outlined,
      Icons.flight_outlined,
      Icons.school_outlined,
      Icons.account_balance_outlined,
      Icons.restaurant_outlined,
      Icons.shopping_bag_outlined,
      Icons.home_outlined,
      Icons.directions_car_outlined,
      Icons.handyman_outlined,
      Icons.apartment_outlined,
    ];
    return icons[index % icons.length];
  }
}
