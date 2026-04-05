import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/controller_layer/Node.dart';
import 'package:myapp/controller_layer/SolverType.dart';

class Agentscontroller {
  //initial and final states
  List<int> tiles = [1, 2, 3, 4, 5, 6, 7, 8, 0];
  List<int> goal = [1, 2, 3, 4, 5, 6, 7, 8, 0];
  List<int>? _lastState;
  Set<String> visited = {};
  SolverType selectedSolver = SolverType.bfs;
  bool useManhattan = true;
  bool isSolving = false;
  Timer? timer;
  int moves = 0;
  int time = 0;
  int nodesExpanded = 0;
  int pathLength = 0;
  int executionTime = 0;

  // ============================= BFS Algorithm =============================
  int? getBFSMove() {
    List<List<int>> path = getBFSPath();
    if (path.length > 1) {
      return path[1].indexOf(0);
    }
    return null;
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

  Future<void> solveWithBFSPath(
    VoidCallback setState,
    VoidCallback showWinDialog,
  ) async {
    final startTime = DateTime.now();
    List<List<int>> path = getBFSPath();
    executionTime = DateTime.now().difference(startTime).inMilliseconds;

    for (int i = 1; i < path.length; i++) {
      if (isSolving == false) return;

      tiles = List.from(path[i]);
      moves++;
      setState();

      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (winState()) {
      timer?.cancel();
      showWinDialog();
      isSolving = false;
    }
  }

  // ============================= Greedy Algorithm =============================
  int? getGreedyMove() {
    List<List<int>> path = getGreedyPath(useManhattan);
    if (path.length > 1) {
      return path[1].indexOf(0);
    }
    return null;
  }

  List<List<int>> getGreedyPath(bool useManhattan) {
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
          int h = useManhattan
              ? manhattanDistance(neighbor)
              : eculideanDistance(neighbor).toInt();

          pq.add(
            Node(
              fScore: h.toDouble(),
              cost: 0,
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

  // ============================= A* Algorithm =============================A*

  int? getAStarMove() {
    List<List<int>> path = getAstarPath(useManhattan);
    if (path.length > 1) {
      return path[1].indexOf(0);
    }
    return null;
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

  Future<void> solveWithAStarPath(
    VoidCallback setState,
    VoidCallback showWinDialog,
  ) async {
    final startTime = DateTime.now();
    List<List<int>> path = getAstarPath(useManhattan);
    executionTime = DateTime.now().difference(startTime).inMilliseconds;

    for (int i = 1; i < path.length; i++) {
      if (isSolving == false) return;

      tiles = List.from(path[i]);
      moves++;
      setState();

      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (winState()) {
      timer?.cancel();
      showWinDialog();
      isSolving = false;
    }
  }

  // ============================= DFS Algorithm =============================
  int? getDFSMove() {
    List<List<int>> path = getDFSPath();
    if (path.length > 1) {
      return path[1].indexOf(0);
    }
    return null;
  }

  // Complete
  List<List<int>> getDFSPath() {
    List<Node> stack = [];
    Set<String> visited = {};
    // int maxDepth = 31; // double check

    Node start = Node(
      fScore: 0,
      cost: 0,
      state: List.from(tiles),
      parent: null,
    );

    stack.add(start);

    while (stack.isNotEmpty) {
      Node currentNode = stack.removeLast();

      // if (currentNode.cost > maxDepth) continue;
      nodesExpanded++;

      String key = currentNode.state.toString();

      //  mark visited AFTER popping
      if (visited.contains(key)) continue;
      visited.add(key);

      List<int> current = currentNode.state;

      if (listEquals(current, goal)) {
        return constructedPath(currentNode);
      }

      List<List<int>> neighbors = getNeighbors(current).reversed.toList();

      for (var neighbor in neighbors) {
        stack.add(
          Node(
            fScore: 0,
            cost: currentNode.cost + 1,
            state: neighbor,
            parent: currentNode,
          ),
        );
      }
    }

    return []; // means failed
  }

  Future<void> solveWithDFSPath(
    VoidCallback setState,
    VoidCallback showWinDialog,
  ) async {
    final startTime = DateTime.now();
    List<List<int>> path = getDFSPath();
    executionTime = DateTime.now().difference(startTime).inMilliseconds;

    for (int i = 1; i < path.length; i++) {
      if (isSolving == false) return;

      tiles = List.from(path[i]);
      moves++;
      setState();

      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (winState()) {
      timer?.cancel();
      showWinDialog();
      isSolving = false;
    }
  }

  //hint mechanism

  int? getHint() {
    switch (selectedSolver) {
      case SolverType.greedy:
        return getGreedyMove();
      case SolverType.bfs:
        return getBFSMove();
      case SolverType.aStar:
        return getAStarMove();
      case SolverType.dfs:
        return getDFSMove();
    }
  }

  //auto solving

  Future<void> autoSolve(
    VoidCallback setState,
    VoidCallback showWinDialog,
  ) async {
    // if (isSolving == true) return;
    nodesExpanded = 0;
    pathLength = 0;
    executionTime = 0;
    isSolving = true;
    visited.clear();

    if (selectedSolver == SolverType.bfs) {
      await solveWithBFSPath(setState, showWinDialog);
      return;
    }
    if (selectedSolver == SolverType.aStar) {
      await solveWithAStarPath(setState, showWinDialog);
      return;
    }

    if (selectedSolver == SolverType.dfs) {
      await solveWithDFSPath(setState, showWinDialog);
      return;
    }

    while (!winState() && isSolving) {
      //if (!mounted) return;

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

      handleTap(hint, setState, showWinDialog);

      if (winState()) break;

      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  // ============================= Heuristics =============================
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

  // ============================= Helper Functions =============================

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

  void handleTap(
    int tileIndex,
    VoidCallback setState,
    VoidCallback showWinDialog,
  ) {
    int emptyIndex = tiles.indexOf(0);

    if (validMove(tileIndex, emptyIndex)) {
      _lastState = List.from(tiles);
      swap(tiles, tileIndex, emptyIndex);
      moves++;

      setState();

      if (winState()) {
        timer?.cancel();
        showWinDialog();
      }
    }
  }

  void shuffle() {
    do {
      tiles.shuffle();
    } while (isSolvable(tiles) == true);

    nodesExpanded = 0;
    executionTime = 0;
    pathLength = 0;

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

  bool isSolvable(List<int> state) {
    int inversions = 0;

    for (int i = 0; i < state.length; i++) {
      for (int j = i + 1; j < state.length; j++) {
        if (state[i] != 0 && state[j] != 0 && state[i] > state[j]) {
          inversions++;
        }
      }
    }
    return inversions % 2 == 0; // If even means solvable
  }
}
