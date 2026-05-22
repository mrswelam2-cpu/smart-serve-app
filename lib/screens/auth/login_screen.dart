import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final String type; // user | craftsman | business
  const LoginScreen({super.key, required this.type});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  String get _title => switch (widget.type) {
    'craftsman' => 'دخول الحرفيين',
    'business'  => 'دخول الأعمال',
    _           => 'تسجيل الدخول',
  };

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      Map<String, dynamic> res;
      if (widget.type == 'craftsman') {
        res = await ApiService.craftsmanLogin(_emailCtrl.text.trim(), _passCtrl.text);
      } else if (widget.type == 'business') {
        res = await ApiService.businessLogin(_emailCtrl.text.trim(), _passCtrl.text);
      } else {
        res = await ApiService.userLogin(_emailCtrl.text.trim(), _passCtrl.text);
      }

      if (res['status'] == true) {
        await ApiService.saveToken(res['token'], widget.type);
        if (!mounted) return;

        if (widget.type == 'craftsman') {
          if (res['setup_needed'] == true) {
            context.go('/craftsman/setup');
          } else {
            context.go('/craftsman/dashboard');
          }
        } else if (widget.type == 'business') {
          context.go('/business/dashboard');
        } else {
          context.go('/');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('بيانات الدخول غير صحيحة'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Logo
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.location_on, color: Colors.white, size: 36),
                  ),
                ),
                const SizedBox(height: 32),

                Text(_title, style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 8),
                Text('أهلاً بك، سجّل دخولك للمتابعة',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 32),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 32),

                // Login Button
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('دخول'),
                ),
                const SizedBox(height: 16),

                // Register Link
                Center(
                  child: TextButton(
                    onPressed: () => context.push('/auth/register/${widget.type}'),
                    child: RichText(
                      text: TextSpan(
                        text: 'مش عندك حساب؟ ',
                        style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Cairo'),
                        children: const [
                          TextSpan(text: 'سجّل الآن',
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),

                // Back
                Center(
                  child: TextButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios, size: 14),
                    label: const Text('رجوع'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
