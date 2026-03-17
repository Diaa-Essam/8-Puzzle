import 'package:flutter/material.dart';
import 'AboutUs.dart';
import 'Settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Home Page", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown,
      ),
      body: Center(
        child: Column(
          children: [
            MaterialButton(
              color: Colors.brown,
              child: Text("Go to About Us"),
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => AboutUs()));
              },
            ),
            MaterialButton(
              color: Colors.brown,
              child: Text("Go to Settings"),
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => Settings()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
