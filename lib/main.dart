import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stores/presentation/providers/theme_provider.dart';
import 'package:stores/presentation/screens/home.dart';
import 'package:stores/presentation/screens/auth/login.dart';
import 'package:stores/presentation/screens/products/add_ProductScreen.dart';
import 'package:stores/presentation/screens/auth/register.dart';

import 'core/theme/app_Theme.dart';
import 'data/datasource/local/authLocal_DataSource.dart';

late SharedPreferences shared;

void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  AuthLocalDataSourceImpl().initDatabase();

  shared = await SharedPreferences.getInstance();


  runApp(const ProviderScope(child: MyApp() ,));
}


class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final themeState = ref.watch(themeProvider);


    return MaterialApp(
      title: 'متجري',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,


      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(isUpdate: false,),
        '/home': (context) => const HomeScreen(),
        '/add-product': (context) => const AddProductScreen(),

      },
    );
  }
}

