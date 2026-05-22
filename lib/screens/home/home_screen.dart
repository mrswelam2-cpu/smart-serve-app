import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/business_card.dart';
import '../../widgets/craftsman_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await ApiService.getHome();
      setState(() { _data = data['data']; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            if (_loading)
              SliverToBoxAdapter(child: _buildShimmer())
            else ...[
              SliverToBoxAdapter(child: _buildSearchBar()),
              if (_data?['categories'] != null) ...[
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'التصنيفات',
                    onViewAll: () => context.push('/categories'),
                  ),
                ),
                SliverToBoxAdapter(child: _buildCategories()),
              ],
              // الأعمال المميزة
              if ((_data?['featured_businesses'] as List?)?.isNotEmpty == true) ...[
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'الأعمال المميزة',
                    onViewAll: () => context.push('/businesses'),
                  ),
                ),
                SliverToBoxAdapter(child: _buildFeaturedBusinesses()),
              ],
              // أحدث الأعمال
              if (_data?['latest_businesses'] != null) ...[
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'أحدث الأعمال',
                    onViewAll: () => context.push('/businesses'),
                  ),
                ),
                SliverToBoxAdapter(child: _buildLatestBusinesses()),
              ],
              // أفضل الحرفيين
              if ((_data?['top_craftsmen'] as List?)?.isNotEmpty == true) ...[
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'أفضل الحرفيين',
                    onViewAll: () => context.push('/craftsmen'),
                  ),
                ),
                SliverToBoxAdapter(child: _buildTopCraftsmen()),
              ],
              // أحدث الحرفيين
              if (_data?['latest_craftsmen'] != null) ...[
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'أحدث الحرفيين',
                    onViewAll: () => context.push('/craftsmen'),
                  ),
                ),
                SliverToBoxAdapter(child: _buildLatestCraftsmen()),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
          child: Row(
            children: [
              Image.network(
                'https://smart-serves.com/logo.png',
                height: 40,
                errorBuilder: (_, __, ___) => const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text('Smart Serve', style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Cairo',
                    )),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text('Smart Serve', style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Cairo',
                  )),
                  Text('ابحث عن أفضل الخدمات', style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  )),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => context.push('/auth/select'),
                icon: const Icon(Icons.person_outline, color: Colors.white, size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () => context.push('/businesses'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textMuted),
              const SizedBox(width: 10),
              Text('ابحث عن شركة أو حرفي...', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = _data!['categories'] as List;
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final cat = categories[i];
          return GestureDetector(
            onTap: () => context.push('/businesses?category=${cat['slug']}'),
            child: SizedBox(
              width: 72,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: _CategoryIcon(index: i),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedBusinesses() {
    final businesses = _data!['featured_businesses'] as List;
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: businesses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => BusinessCard(business: businesses[i], compact: true),
      ),
    );
  }

  Widget _buildLatestBusinesses() {
    final businesses = _data!['latest_businesses'] as List;
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: businesses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => BusinessCard(business: businesses[i], compact: true),
      ),
    );
  }

  Widget _buildTopCraftsmen() {
    final craftsmen = _data!['top_craftsmen'] as List;
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: craftsmen.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => CraftsmanCard(craftsman: craftsmen[i], compact: true),
      ),
    );
  }

  Widget _buildLatestCraftsmen() {
    final craftsmen = _data!['latest_craftsmen'] as List;
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: craftsmen.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => CraftsmanCard(craftsman: craftsmen[i], compact: true),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(3, (_) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 80,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        )),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final int index;
  const _CategoryIcon({required this.index});

  static const _icons = [
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

  @override
  Widget build(BuildContext context) {
    final icon = _icons[index % _icons.length];
    return Icon(icon, color: AppColors.primary, size: 28);
  }
}
