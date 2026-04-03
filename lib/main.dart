import 'package:flutter/material.dart';
import 'package:myapp/prestation_layer/Puzzle.dart';

void main() => runApp(const AmigoApp());

class AmigoApp extends StatelessWidget {
  const AmigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Puzzle(),
    ); //hello diaa, hi Nashaat
  }
}
