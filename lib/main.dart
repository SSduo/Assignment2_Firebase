import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/product_manager_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Manager (Firestore)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProductManagerFirestore(),
      debugShowCheckedModeBanner: false,
    );
  }
}