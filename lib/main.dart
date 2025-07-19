import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareignadmin/providers/loginprovider/login_provider.dart';
import 'package:svareignadmin/views/loginScreen/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const LoginScreen(),
      ),
    );
  }
}
