import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stores/presentation/screens/home.dart';
import 'package:stores/presentation/screens/auth/login.dart';
import 'package:stores/presentation/screens/products/add_ProductScreen.dart';
import 'package:stores/presentation/screens/auth/register.dart';

import 'data/datasource/local/authLocal_DataSource.dart';

late SharedPreferences shared;

void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  AuthLocalDataSourceImpl().initDatabase();

  shared = await SharedPreferences.getInstance();


  runApp(const ProviderScope(child: MyApp() ,));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'متجري',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
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


