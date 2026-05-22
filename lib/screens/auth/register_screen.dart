import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  final String type;
  const RegisterScreen({super.key, required this.type});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  String get _title => switch (widget.type) {
    'craftsman' => 'تسجيل حرفي جديد',
    'business'  => 'تسجيل نشاط تجاري',
    _           => 'إنشاء حساب',
  };

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('كلمتا المرور غير متطابقتان'),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    setState(() => _loading = true);

    try {
      Map<String, dynamic> res;
      final data = {
        'firstname': _firstCtrl.text.trim(),
        'lastname': _lastCtrl.text.trim(),
        'username': _userCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passCtrl.text,
        'password_confirmation': _confirmCtrl.text,
      };

      if (widget.type == 'craftsman') {
        res = await ApiService.craftsmanRegister(data);
      } else {
        res = await ApiService.userRegister(data);
      }

      if (res['status'] == true) {
        await ApiService.saveToken(res['token'], widget.type);
        if (!mounted) return;
        if (widget.type == 'craftsman') {
          context.go('/craftsman/setup');
        } else {
          context.go('/');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('حدث خطأ، حاول مرة أخرى'),
        backgroundColor: AppColors.error,
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(children: [
                Expanded(child: TextFormField(
                  controller: _firstCtrl,
                  decoration: const InputDecoration(labelText: 'الاسم الأول'),
                  validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                )),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(
                  controller: _lastCtrl,
                  decoration: const InputDecoration(labelText: 'اسم العائلة'),
                  validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                )),
              ]),
              const SizedBox(height: 16),
              TextFormField(
                controller: _userCtrl,
                decoration: const InputDecoration(labelText: 'اسم المستخدم', prefixIcon: Icon(Icons.alternate_email)),
                validator: (v) => v!.isEmpty ? 'مطلوب' : v.length < 3 ? 'أقل 3 أحرف' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email_outlined)),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
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
                validator: (v) => v!.length < 8 ? 'أقل 8 أحرف' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('إنشاء الحساب'),
              ),
              const SizedBox(height: 16),
              Center(child: TextButton(
                onPressed: () => context.push('/auth/login/${widget.type}'),
                child: RichText(text: const TextSpan(
                  text: 'عندك حساب؟ ',
                  style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Cairo'),
                  children: [TextSpan(text: 'سجّل دخول',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))],
                )),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
