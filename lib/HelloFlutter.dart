import 'package:flutter/material.dart';

// class HelloFlutter extends StatefulWidget {
//   const HelloFlutter({super.key});
//   @override
//   State<HelloFlutter> createState() => _AboutUsState();
// }

class HelloFlutter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("8 Puzzle"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [buildTile(), buildTile(), buildTile()],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [buildTile(), buildTile(), buildTile()],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [buildTile(), buildTile(), buildTile()],
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildTile() {
  return Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(border: Border.all()),
  );
}
