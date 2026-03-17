import 'package:flutter/material.dart';
import 'package:myapp/HelloFlutter.dart';

void main() => runApp(const AmigoApp());

class AmigoApp extends StatelessWidget {
  const AmigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HelloFlutter());
  }
}
