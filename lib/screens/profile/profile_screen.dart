import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userType;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await ApiService.getToken();
    final type = await ApiService.getUserType();
    setState(() { _userType = token != null ? type : null; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));

    if (_userType == null) return _buildGuestView(context);
    if (_userType == 'craftsman') {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/craftsman/dashboard'));
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }
    if (_userType == 'business') {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/business/dashboard'));
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }

    return _buildUserProfile(context);
  }

  Widget _buildGuestView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline, color: AppColors.primary, size: 52),
              ),
              const SizedBox(height: 24),
              Text('مرحباً بك!', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text('سجّل دخولك للوصول لحسابك',
                  style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.push('/auth/select'),
                child: const Text('تسجيل الدخول'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push('/auth/register/user'),
                child: const Text('إنشاء حساب جديد'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        actions: [
          IconButton(
            onPressed: () async {
              await ApiService.clearToken();
              if (!mounted) return;
              setState(() => _userType = null);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white, size: 52),
              ),
              const SizedBox(height: 20),
              Text('أهلاً بك!', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text('أنت مسجّل كطالب خدمة', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }
}
