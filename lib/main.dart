import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareignadmin/providers/loginprovider/login_provider.dart';
import 'package:svareignadmin/viewmodel/userviewmde/user_view_model.dart';
import 'package:svareignadmin/views/loginScreen/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(
          create: (_) => UserViewModel(),
        ), // ✅ User ViewModel for admin side
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Svareign Admin',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: Colors.grey.shade100,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
