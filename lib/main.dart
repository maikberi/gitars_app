import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gitars_app/parser.dart';

import 'homepage.dart';

void main() async {
  Parser parser = Parser();
  //parser.getsong();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.grey.shade900,
  ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
