import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stores/Domain/entities/user_entity.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, required this.isUpdate, this.data});

  final bool isUpdate;
  final UserEntity? data;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true; // لإظهار/إخفاء كلمة المرور


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(widget.isUpdate){
      _usernameController.text = widget.data!.name;
      _phoneController.text = widget.data!.phone;
      _emailController.text = widget.data!.email;
    }

  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // الاستماع للتغييرات في حالة المصادقة
    ref.listen<AuthState>(authProvider, (previous, next) {
      // الانتقال إلى صفحة تسجيل الدخول فقط عند نجاح التسجيل
      if (next.isAuthenticated && next.user != null && next.error == null) {
        // استخدم addPostFrameCallback لتجنب أخطاء البناء
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {

            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                content: Text( !widget.isUpdate ? 'تم إنشاء الحساب بنجاح! الرجاء تسجيل الدخول' : 'تم تحديث البيانات بنجاح'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            // إعادة تعيين حالة المصادقة
            // الانتقال إلى صفحة تسجيل الدخول
            if(!widget.isUpdate ) {
              Navigator.pushReplacementNamed(context, '/login');
              ref.read(authProvider.notifier).logout();
            }


          }
        });
      }

      // عرض رسالة الخطأ
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(!widget.isUpdate ? 'إنشاء حساب جديد' : 'تحديث البيانات'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // حقل اسم المستخدم
                TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المستخدم',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال اسم المستخدم';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // حقل رقم الهاتف
                TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال رقم الهاتف';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // حقل البريد الإلكتروني
                TextFormField(
                  textInputAction: TextInputAction.next,
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

                // حقل كلمة المرور
                !widget.isUpdate ?
                TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    }
                    if (value.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                )  : SizedBox(),

                // زر إنشاء الحساب
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authState.isLoading
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) {
                        // استدعاء دالة التسجيل


                        widget.isUpdate ?
                        ref.read(authProvider.notifier).update(
                          name: _usernameController.text.trim(),
                          email: _emailController.text.trim(),
                          phone: _phoneController.text.trim(),
                        )

                        :
                        ref.read(authProvider.notifier).register(
                          name: _usernameController.text.trim(),
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                          phone: _phoneController.text.trim(),
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
                    ) :  Text(
                      !widget.isUpdate ? 'إنشاء حساب جديد' : 'تحديث البيانات',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                !widget.isUpdate ?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text('لديك حساب بالفعل'),
                    SizedBox(width: 5,),
                    InkWell(
                      onTap: () {
                        ref.read(authProvider.notifier).clearError();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text('تسجيل الدخول' , style: TextStyle(color: Colors.blue , fontWeight: FontWeight.bold),),

                    )
                  ],
                ) : SizedBox()

              ],
            ),
          ),
        ),
      ),
    );
  }
}