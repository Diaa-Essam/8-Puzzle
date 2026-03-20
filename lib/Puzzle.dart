import 'dart:math';

import 'package:flutter/material.dart';

class Puzzle extends StatefulWidget {
  const Puzzle({super.key});
  @override
  State<Puzzle> createState() => _PuzzleState();
}

class _PuzzleState extends State<Puzzle> {
  List<int> tiles = [1, 2, 3, 4, 5, 6, 7, 8, 0];
  @override
  void initState() {
    shuffle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text("8-Puzzle", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.brown[100],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [buildTile(0), buildTile(1), buildTile(2)],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [buildTile(3), buildTile(4), buildTile(5)],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [buildTile(6), buildTile(7), buildTile(8)],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTile(int tileIndex) {
    int emptyIndex = tiles.indexOf(0);
    int value = tiles[tileIndex];
    return GestureDetector(
      onTap: () {
        if (validMove(tileIndex, emptyIndex)) {
          setState(() {
            swap(tiles, tileIndex, emptyIndex);
          });
          if (winState()) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => AlertDialog(
                title: Text("You Win 🎉"),
                content: Text("Congratulations!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        shuffle();
                      });
                    },
                    child: Text("Restart"),
                  ),
                ],
              ),
            );
          }
        } else {
          print("Not A Valid Move");
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        width: 80,
        height: 80,
        margin: EdgeInsets.all(3),
        decoration: BoxDecoration(
          boxShadow: value == 0
              ? []
              : [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
          borderRadius: BorderRadius.circular(12),
          color: value == 0 ? Colors.transparent : Colors.brown,
          border: Border.all(),
        ),
        child: Center(
          child: Text(
            value == 0 ? "" : "${value}",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  bool validMove(int tileIndex, int emptyIndex) {
    if (emptyIndex == tileIndex + 1 && emptyIndex ~/ 3 == tileIndex ~/ 3 ||
        emptyIndex == tileIndex - 1 && emptyIndex ~/ 3 == tileIndex ~/ 3 ||
        emptyIndex == tileIndex + 3 ||
        emptyIndex == tileIndex - 3) {
      return true;
    }
    return false;
  }

  void swap(List<int> tiles, int tileIndex, int emptyIndex) {
    int temp = tiles[tileIndex];
    tiles[tileIndex] = tiles[emptyIndex];
    tiles[emptyIndex] = temp;
  }

  bool winState() {
    for (int i = 0; i < tiles.length - 1; i++) {
      if (i + 1 != tiles[i]) {
        return false;
      }
    }
    return true;
  }

  void shuffle() {
    // reset tiles to solved
    // shuffle again
    tiles = [1, 2, 3, 4, 5, 6, 7, 8, 0];
    while (winState()) {
      for (int c = 0; c < 4; c++) {
        List<int> possibleMoves = [];
        int emptyIndex = tiles.indexOf(0);
        for (int i = 0; i < 9; i++) {
          if (validMove(i, emptyIndex)) {
            possibleMoves.add(i);
          }
        }
        int pickedTile = possibleMoves[Random().nextInt(possibleMoves.length)];
        swap(tiles, pickedTile, emptyIndex);
      }
    }
  }
}
