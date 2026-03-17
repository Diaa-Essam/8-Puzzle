import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'Settings.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});
  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("About Us", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown,
      ),
      body: Center(
        child: Column(
          children: [
            MaterialButton(
              color: Colors.brown,
              child: Text("Go to Home Page"),
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => HomePage()));
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
