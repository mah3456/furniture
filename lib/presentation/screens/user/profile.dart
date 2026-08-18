import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../main.dart';
import '../../providers/auth_provider.dart';
import '../auth/register.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {

              // final uid = await shared.getString('user_id');


              ref.read(authProvider.notifier).refreshUserData();


            },
          ),
        ],

        title: const Text('حسابي'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // صورة المستخدم
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    authState.user?.name.isNotEmpty == true
                        ? authState.user!.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // اسم المستخدم
              Text(
                authState.user?.name ?? 'مستخدم',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                authState.user?.email ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              // بطاقة المعلومات
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.person,
                        'الاسم',
                        authState.user?.name ?? 'غير معروف',
                      ),
                      const Divider(),
                      _buildInfoRow(
                        Icons.email,
                        'البريد الإلكتروني',
                        authState.user?.email ?? 'غير معروف',
                      ),
                      const Divider(),
                      _buildInfoRow(
                        Icons.phone,
                        'رقم الهاتف',
                        authState.user?.phone ?? 'غير معروف',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // أزرار الإجراءات
              _buildActionButton(
                icon: Icons.edit,
                label: 'تعديل الملف الشخصي',
                onPressed: () {
                 Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegisterScreen(isUpdate: true, data: authState.user)));
                },
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                icon: Icons.settings,
                label: 'الإعدادات',
                onPressed: () {

                },
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                icon: Icons.logout,
                label: 'تسجيل الخروج',
                isDestructive: true,
                onPressed: () {
                  _showLogoutDialog(context, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive ? Colors.red : Colors.white,
          foregroundColor: isDestructive ? Colors.white : Colors.blue,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDestructive ? Colors.red : Colors.blue.shade200,
            ),
          ),
          elevation: isDestructive ? 2 : 0,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                    (route) => false,
              );
            },
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}