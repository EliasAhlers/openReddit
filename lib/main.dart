import 'package:flutter/material.dart';
import 'package:openReddit/screens/loginScreen.dart';

// void main() => runApp(MyApp());

main() {
  runApp(MyApp());
} 

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'openReddit',
      theme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          color: Colors.black87
        )
      ),
      home: LoginScreen(),
    );
  }
}
