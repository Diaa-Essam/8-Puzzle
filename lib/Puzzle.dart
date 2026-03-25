import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'Tile.dart';

class Puzzle extends StatefulWidget {
  const Puzzle({super.key});

  @override
  State<Puzzle> createState() => _PuzzleState();
}

class _PuzzleState extends State<Puzzle> {
  List<int> tiles = [1, 2, 3, 4, 5, 6, 7, 8, 0];
  int moves = 0;
  int time = 0;
  Timer? timer;

  @override
  void initState() {
    shuffle();
    _startCountUp();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text("8-Puzzle", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.brown[100],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Moves: $moves\nTimer: ${formatTime(time)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Row 1
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TileWidget(value: tiles[0], onTap: () => handleTap(0)),
                  TileWidget(value: tiles[1], onTap: () => handleTap(1)),
                  TileWidget(value: tiles[2], onTap: () => handleTap(2)),
                ],
              ),

              // Row 2
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TileWidget(value: tiles[3], onTap: () => handleTap(3)),
                  TileWidget(value: tiles[4], onTap: () => handleTap(4)),
                  TileWidget(value: tiles[5], onTap: () => handleTap(5)),
                ],
              ),

              // Row 3
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TileWidget(value: tiles[6], onTap: () => handleTap(6)),
                  TileWidget(value: tiles[7], onTap: () => handleTap(7)),
                  TileWidget(value: tiles[8], onTap: () => handleTap(8)),
                ],
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    shuffle();
                    _startCountUp();
                  });
                },
                child: const Text("Restart"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleTap(int tileIndex) {
    int emptyIndex = tiles.indexOf(0);

    if (validMove(tileIndex, emptyIndex)) {
      setState(() {
        swap(tiles, tileIndex, emptyIndex);
        moves++;
      });

      if (winState()) {
        timer?.cancel();
        showWinDialog();
      }
    } else {
      print("Not A Valid Move");
    }
  }

  bool validMove(int tileIndex, int emptyIndex) {
    return (emptyIndex == tileIndex + 1 && emptyIndex ~/ 3 == tileIndex ~/ 3) ||
        (emptyIndex == tileIndex - 1 && emptyIndex ~/ 3 == tileIndex ~/ 3) ||
        emptyIndex == tileIndex + 3 ||
        emptyIndex == tileIndex - 3;
  }

  void swap(List<int> tiles, int tileIndex, int emptyIndex) {
    int temp = tiles[tileIndex];
    tiles[tileIndex] = tiles[emptyIndex];
    tiles[emptyIndex] = temp;
  }

  bool winState() {
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return true;
  }

  void shuffle() {
    moves = 0;
    time = 0;
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

  void _startCountUp() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        time++;
      });
    });
  }

  void showWinDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("You Win 🎉"),
        content: const Text("Congratulations!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                shuffle();
                _startCountUp();
              });
            },
            child: const Text("Restart"),
          ),
        ],
      ),
    );
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    String m = minutes.toString().padLeft(2, '0');
    String s = remainingSeconds.toString().padLeft(2, '0');

    return "$m:$s";
  }
}
