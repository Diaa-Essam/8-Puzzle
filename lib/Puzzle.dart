import 'dart:collection';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for listEquals
import 'package:myapp/Node.dart';
import 'Tile.dart';

class Puzzle extends StatefulWidget {
  const Puzzle({super.key});

  @override
  State<Puzzle> createState() => _PuzzleState();
}

enum SolverType { greedy, bfs, aStar }

class _PuzzleState extends State<Puzzle> {
  List<int> tiles = [1, 2, 3, 4, 5, 6, 7, 8, 0];
  final List<int> goal = [1, 2, 3, 4, 5, 6, 7, 8, 0];
  int moves = 0;
  int time = 0;
  Timer? timer;

  Set<String> visited = {};
  List<int>? _lastState;
  bool useManhattan = true;

  SolverType _selectedSolver = SolverType.greedy;

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
                  padding: const EdgeInsets.all(10),
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
                                  onPressed: () => Navigator.of(context).pop(),
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
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          int? hint = getHint();
                          if (hint != null) handleTap(hint);
                        },
                        child: const Text("Hint"),
                      ),
                    ),
                    const SizedBox(width: 15),
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Solver: "),
                    DropdownButton<SolverType>(
                      value: _selectedSolver,
                      items: const [
                        DropdownMenuItem(
                          value: SolverType.greedy,
                          child: Text("Greedy"),
                        ),
                        DropdownMenuItem(
                          value: SolverType.bfs,
                          child: Text("BFS"),
                        ),
                        DropdownMenuItem(
                          value: SolverType.aStar,
                          child: Text("A*"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedSolver = value!;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Heuristic: "),
                    DropdownButton<bool>(
                      value: useManhattan,
                      items: const [
                        DropdownMenuItem(
                          value: true,
                          child: Text("Manhanttan"),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text("Euclidean"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          useManhattan = value!;
                        });
                      },
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

  void handleTap(int tileIndex) {
    int emptyIndex = tiles.indexOf(0);

    if (validMove(tileIndex, emptyIndex)) {
      setState(() {
        _lastState = List.from(tiles);
        swap(tiles, tileIndex, emptyIndex);
        moves++;
      });

      if (winState()) {
        timer?.cancel();
        showWinDialog();
      }
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
    _lastState = null;
    moves = 0;
    time = 0;

    tiles = List.from(goal);

    for (int c = 0; c < 10; c++) {
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

  // Testing
  double eculideanDistance(List<int> state) {
    double distance = 0;

    for (int i = 0; i < state.length; i++) {
      int value = state[i];
      if (value == 0) continue;

      int currentRow = i ~/ 3;
      int currentCol = i % 3;

      int goalRow = (value - 1) ~/ 3;
      int goalCol = (value - 1) % 3;

      distance += sqrt(
        pow(currentRow - goalRow, 2) + pow(currentCol - goalCol, 2),
      );
    }

    return distance;
  }

  List<List<int>> getNeighbors(List<int> state) {
    List<List<int>> result = [];

    int emptyIndex = state.indexOf(0);

    for (int i = 0; i < state.length; i++) {
      if (validMove(i, emptyIndex)) {
        List<int> newState = List.from(state);
        swap(newState, i, emptyIndex);
        result.add(newState);
      }
    }

    return result;
  }

  int? getGreedyMove() {
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

      if (_lastState != null && listEquals(temp, _lastState!)) continue;
      if (visited.contains(temp.toString())) continue;

      int score = useManhattan
          ? manhattanDistance(temp)
          : eculideanDistance(temp).toInt();

      if (score < bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    if (bestMove == null && possibleMoves.isNotEmpty) {
      bestMove = possibleMoves[Random().nextInt(possibleMoves.length)];
    }

    return bestMove;
  }

  int? getAStarMove() {
    return null; // clean placeholder
  }

  int? getBFSMove() {
    Queue<Node> queue = Queue();
    Set<String> visited = {};
    Node start = Node(cost: 0, state: List.from(tiles), parent: null);

    queue.add(start);
    visited.add(start.state.toString());
    List<List<int>> path = [];
    while (queue.isNotEmpty) {
      Node currentNode = queue.removeFirst();
      List<int> current = currentNode.state;

      if (listEquals(current, goal)) {
        Node goalNode = currentNode;

        Node? temp = goalNode;

        while (temp != null) {
          path.add(temp.state);
          temp = temp.parent;
        }
        path = path.reversed.toList();
        break;
      }

      List<List<int>> neighbors = getNeighbors(current);
      for (var neighbor in neighbors) {
        String key = neighbor.toString();

        if (!visited.contains(key)) {
          visited.add(key);
          queue.add(
            Node(
              cost: currentNode.cost + 1,
              state: neighbor,
              parent: currentNode,
            ),
          );
        }
      }
    }

    if (path.length > 1) {
      List<int> nextState = path[1];

      int emptyIndex = tiles.indexOf(0);
      for (int i = 0; i < 9; i++) {
        if (tiles[i] != nextState[i]) {
          if (validMove(i, emptyIndex)) {
            return i;
          }
        }
      }
    }
  }

  Future<void> autoSolve() async {
    visited.clear();
    int maxSteps = 1000;

    while (!winState() && maxSteps > 0) {
      if (!mounted) return;

      visited.add(tiles.toString());

      int? hint = getHint(); // This decide based on the _selectedSolver

      if (hint == null) {
        // fallback random
        int emptyIndex = tiles.indexOf(0);
        List<int> possibleMoves = [];

        for (int i = 0; i < 9; i++) {
          if (validMove(i, emptyIndex)) {
            possibleMoves.add(i);
          }
        }

        if (possibleMoves.isEmpty) break;

        hint = possibleMoves[Random().nextInt(possibleMoves.length)];
      }

      handleTap(hint);

      if (winState()) break;

      await Future.delayed(const Duration(milliseconds: 300));
      maxSteps--;
    }
  }

  int? getHint() {
    switch (_selectedSolver) {
      case SolverType.greedy:
        return getGreedyMove();
      case SolverType.bfs:
        return getBFSMove();
      case SolverType.aStar:
        return getAStarMove();
    }
  }

  void showWinDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("You Win 🎉"),
        content: Text(
          "You solved it in $moves moves!\nTime: ${formatTime(time)}",
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
}
