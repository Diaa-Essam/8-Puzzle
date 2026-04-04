import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart'; // for listEquals
import 'package:flutter/material.dart';
import 'package:myapp/controller_layer/Node.dart';
import 'package:myapp/presentation_layer/TileWidget.dart';

class Puzzle extends StatefulWidget {
  const Puzzle({super.key});

  @override
  State<Puzzle> createState() => _PuzzleState();
}

enum SolverType { greedy, bfs, AStar }

class _PuzzleState extends State<Puzzle> {
  List<int> tiles = [1, 2, 3, 4, 5, 6, 7, 8, 0];
  final List<int> goal = [1, 2, 3, 4, 5, 6, 7, 8, 0];
  int moves = 0;
  int time = 0;
  Timer? timer;
  int nodesExpanded = 0;
  int pathLength = 0;
  int executionTime = 0;

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

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.brown[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Nodes Expanded:$nodesExpanded\nPath Length: $pathLength\nExecution Time: ${executionTime} ms",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

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
                          value: SolverType.AStar,
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
  //====================================== Logic Section ======================================

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

    for (int c = 0; c < 100; c++) {
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

  int? getGreedyMove(bool useManhattan) {
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
    List<List<int>> path = getAstarPath(useManhattan);
    if (path.length > 1) {
      return path[1].indexOf(0);
    }
    return null;
  }

  int? getBFSMove() {
    List<List<int>> path = getBFSPath();
    if (path.length > 1) {
      return path[1].indexOf(0);
    }
    return null;
  }

  List<List<int>> constructedPath(Node? temp) {
    List<List<int>> path = [];
    while (temp != null) {
      path.add(temp.state);
      temp = temp.parent;
    }
    path = path.reversed.toList();
    pathLength = path.length - 1;
    return path;
  }

  List<List<int>> getAstarPath(bool useManhattan) {
    Set<String> visited = {};
    PriorityQueue<Node> pq = PriorityQueue<Node>(
      (a, b) => a.fScore.compareTo(b.fScore),
    );

    Node start = Node(
      state: List.from(tiles),
      parent: null,
      cost: 0,
      fScore: useManhattan
          ? manhattanDistance(tiles).toDouble()
          : eculideanDistance(tiles),
    );

    pq.add(start);
    visited.add(start.state.toString());

    while (pq.isNotEmpty) {
      Node currentNode = pq.removeFirst();
      nodesExpanded++;
      List<int> current = currentNode.state;

      if (listEquals(current, goal)) {
        Node goalNode = currentNode;

        Node? temp = goalNode;
        return constructedPath(temp);
      }
      List<List<int>> neighbors = getNeighbors(current);
      for (var neighbor in neighbors) {
        String key = neighbor.toString();

        if (!visited.contains(key)) {
          int g = currentNode.cost + 1;
          int h = useManhattan
              ? manhattanDistance(neighbor)
              : eculideanDistance(neighbor).toInt();

          pq.add(
            Node(
              fScore: (g + h).toDouble(),
              cost: g,
              state: neighbor,
              parent: currentNode,
            ),
          );
          visited.add(key);
        }
      }
    }
    return [];
  }

  List<List<int>> getBFSPath() {
    Queue<Node> queue = Queue();
    Set<String> visited = {};
    Node start = Node(
      fScore: 0,
      cost: 0,
      state: List.from(tiles),
      parent: null,
    );

    queue.add(start);
    visited.add(start.state.toString());

    while (queue.isNotEmpty) {
      Node currentNode = queue.removeFirst();
      nodesExpanded++;
      List<int> current = currentNode.state;

      if (listEquals(current, goal)) {
        Node goalNode = currentNode;

        Node? temp = goalNode;

        return constructedPath(temp);
      }

      List<List<int>> neighbors = getNeighbors(current);
      for (var neighbor in neighbors) {
        String key = neighbor.toString();

        if (!visited.contains(key)) {
          int g = currentNode.cost + 1;
          int f = g;

          queue.add(
            Node(
              fScore: f.toDouble(),
              cost: g,
              state: neighbor,
              parent: currentNode,
            ),
          );
          visited.add(key);
        }
      }
    }
    return [];
  }

  Future<void> autoSolve() async {
    nodesExpanded = 0;
    pathLength = 0;
    executionTime = 0;

    visited.clear();

    if (_selectedSolver == SolverType.bfs) {
      await solveWithBFSPath();
      return;
    }
    if (_selectedSolver == SolverType.AStar) {
      await solveWithAStarPath();
      return;
    }

    while (!winState()) {
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
    }
  }

  Future<void> solveWithBFSPath() async {
    final startTime = DateTime.now();
    List<List<int>> path = getBFSPath();
    executionTime = DateTime.now().difference(startTime).inMilliseconds;

    for (int i = 1; i < path.length; i++) {
      if (!mounted) return;

      setState(() {
        tiles = List.from(path[i]);
        moves++;
      });

      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (winState()) {
      timer?.cancel();
      showWinDialog();
    }
  }

  Future<void> solveWithAStarPath() async {
    final startTime = DateTime.now();
    List<List<int>> path = getAstarPath(useManhattan);
    executionTime = DateTime.now().difference(startTime).inMilliseconds;

    for (int i = 1; i < path.length; i++) {
      if (!mounted) return;

      setState(() {
        tiles = List.from(path[i]);
        moves++;
      });

      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (winState()) {
      timer?.cancel();
      showWinDialog();
    }
  }

  int? getHint() {
    switch (_selectedSolver) {
      case SolverType.greedy:
        return getGreedyMove(useManhattan);
      case SolverType.bfs:
        return getBFSMove();
      case SolverType.AStar:
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
