import 'package:flutter/material.dart';

import 'package:comanager/pages/signin.dart';
import 'package:comanager/pages/signup.dart';
import 'package:comanager/pages/ManagerHomePage.dart';
import 'package:comanager/pages/WorkerHomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      routes: {
        '/signin' : (context) => SigninPage(),
        '/signup' : (context) => SignupPage(),
        '/manager' : (context) => ManagerHomePage(),
        '/worker' : (context) => WorkerHomePage(),
      },
      home: const SigninPage(),
    );
  }
}