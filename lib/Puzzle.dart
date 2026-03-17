import 'package:flutter/material.dart';

// class HelloFlutter extends StatefulWidget {
//   const HelloFlutter({super.key});
//   @override
//   State<HelloFlutter> createState() => _AboutUsState();
// }

class Puzzle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text("8-Puzzle", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [buildTile("1"), buildTile("2"), buildTile("3")],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [buildTile("4"), buildTile("5"), buildTile("6")],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [buildTile("7"), buildTile("8"), buildTile("")],
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildTile(String text) {
  return GestureDetector(
    onTap: () {
      if (text.isNotEmpty) {
        print("Tapped Tile: $text");
      }
    },
    child: Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: text == "" ? Colors.transparent : Colors.white,
        border: Border.all(),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}
