import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'package:svareignadmin/providers/loginprovider/login_provider.dart';
import 'package:svareignadmin/viewmodel/userviewmde/user_view_model.dart';
import 'package:svareignadmin/views/loginScreen/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Quick Firestore test
  try {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    print("Fetched ${snapshot.docs.length} users");
    for (var doc in snapshot.docs) {
      print("Doc: ${doc.id} => ${doc.data()}");
    }
  } catch (e) {
    print("Error fetching users: $e");
  }

  // Run the app once
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
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
