import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../DatabaseHelper.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // الاستماع للتغييرات في حالة المصادقة
    ref.listen<AuthState>(authProvider, (previous, next) {
      // الانتقال إلى الشاشة الرئيسية فقط عند نجاح تسجيل الدخول
      if (next.isAuthenticated && next.user != null) {
        // تأكد من أن هذا يحدث فقط بعد تسجيل دخول ناجح
        print('تم تسجيل الدخول بنجاح للمستخدم: ${next.user!.email}');

        // استخدم addPostFrameCallback لتجنب أخطاء البناء
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: TextButton(
          child: Text('data' , style: TextStyle(color: Colors.white),),

          onPressed: () async{

           final ues =await DatabaseHelpertest().getTableColumnNames('users');
           final prod =await DatabaseHelpertest().getTableColumnNames('products');

           final tal = await DatabaseHelpertest().getAllTables();

           print(ues);
           print(prod);

           print(tal);

          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // عرض رسالة الخطأ إذا وجدت
              if (authState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.error!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          ref.read(authProvider.notifier).clearError();
                        },
                      ),
                    ],
                  ),
                ),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال البريد الإلكتروني';
                  }
                  if (!value.contains('@')) {
                    return 'بريد إلكتروني غير صالح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: Icon(Icons.visibility),
                ),
                obscureText: false, // غيرها إلى true لإخفاء كلمة المرور
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال كلمة المرور';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: authState.isLoading
                      ? null
                      : () {
                    // مسح الخطأ السابق عند محاولة جديدة
                    ref.read(authProvider.notifier).clearError();

                    if (_formKey.currentState!.validate()) {
                      ref.read(authProvider.notifier).login(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'تسجيل الدخول',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 16),


              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textDirection: TextDirection.rtl,
                children: [
                  Text('ليس لديك حساب ؟ '),
                  SizedBox(width: 5,),
                  InkWell(
                    onTap: () {
                      ref.read(authProvider.notifier).clearError();
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text('إنشاء حساب جديد' , style: TextStyle(color: Colors.blue , fontWeight: FontWeight.bold),),

                  )
                ],
              )


            ],
          ),
        ),
      ),
    );
  }
}

