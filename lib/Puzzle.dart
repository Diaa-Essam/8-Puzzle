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
  final List<int> goal = [1, 2, 3, 4, 5, 6, 7, 8, 0];
  int moves = 0;
  int time = 0;
  Timer? timer;
  Set<String> visited = {};
  int bestScore = 1 << 30;

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.brown,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Moves: $moves\nTimer: ${formatTime(time)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: 260,
                  height: 260,
                  child: GridView.builder(
                    itemCount: 9,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                    itemBuilder: (context, index) {
                      int emptyIndex = tiles.indexOf(0);
                      bool isMovable = validMove(index, emptyIndex);
                      return TileWidget(
                        value: tiles[index],
                        onTap: isMovable ? () => handleTap(index) : null,
                        isMovable: isMovable,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Are you sure?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      shuffle();
                                      _startCountUp();
                                    });
                                  },
                                  child: const Text("Confirm"),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text("Restart"),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          int? hint = getBestMove();
                          if (hint != null) {
                            handleTap(hint);
                          }
                        },
                        child: const Text("Hint"),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await autoSolve();
                        },
                        child: const Text("Auto Solver"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showWinDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "You Win 🎉",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "You solved it in $moves moves!\nTime: ${formatTime(time)}",
            textAlign: TextAlign.center,
          ),
        ),
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
      // We can put pop up here
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
    visited.clear();
    moves = 0;
    time = 0;
    tiles = [1, 2, 3, 4, 5, 6, 7, 8, 0];

    while (winState()) {
      for (int c = 0; c < 400; c++) {
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

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    String m = minutes.toString().padLeft(2, '0');
    String s = remainingSeconds.toString().padLeft(2, '0');

    return "$m:$s";
  }

  int manhattanDistance(List<int> state) {
    int distance = 0;

    for (int i = 0; i < state.length; i++) {
      int value = state[i];
      if (value == 0) continue;

      int currentRow = i ~/ 3;
      int currentCol = i % 3;

      int goalRow = (value - 1) ~/ 3;
      int goalCol = (value - 1) % 3;

      distance += (currentRow - goalRow).abs() + (currentCol - goalCol).abs();
    }

    return distance;
  }

  int? getBestMove() {
    int emptyIndex = tiles.indexOf(0);
    List<int> possibleMoves = [];

    for (int i = 0; i < 9; i++) {
      if (validMove(i, emptyIndex)) {
        possibleMoves.add(i);
      }
    }

    int? bestMove;
    int bestScore = 1 << 30;

    for (int move in possibleMoves) {
      List<int> temp = List.from(tiles);
      swap(temp, move, emptyIndex);

      if (visited.contains(temp.toString())) continue;

      int score = manhattanDistance(temp);

      if (score < bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }

  Future<void> autoSolve() async {
    int safety = 1000;

    while (!winState() && safety > 0) {
      if (!mounted) return;

      visited.add(tiles.toString());

      int? hint = getBestMove();
      if (hint == null) break;

      handleTap(hint);

      if (winState()) break;

      await Future.delayed(const Duration(milliseconds: 300));

      safety--;
    }
  }
}
