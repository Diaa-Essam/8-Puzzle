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
  SolverType selectedSolver = SolverType.greedy;
  Timer? timer;
  int moves = 0;
  int time = 0;

  //bfs
  int? getBFSMove() {
    List<List<int>> path = getBFSPath();
    if (path.length > 1) {
      return path[1].indexOf(0);
    }
    return null;
  }

  List<List<int>> getBFSPath() {
    List<List<int>> path = [];
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
      List<int> current = currentNode.state;

      if (listEquals(current, goal)) {
        Node goalNode = currentNode;

        Node? temp = goalNode;

        while (temp != null) {
          path.add(temp.state);
          temp = temp.parent;
        }
        path = path.reversed.toList();
        return path;
      }

      List<List<int>> neighbors = getNeighbors(current);
      for (var neighbor in neighbors) {
        String key = neighbor.toString();

        if (!visited.contains(key)) {
          visited.add(key);
          queue.add(
            Node(
              fScore: currentNode.cost + 1,
              cost: currentNode.cost + 1,
              state: neighbor,
              parent: currentNode,
            ),
          );
        }
      }
    }
    return [];
  }

  Future<void> solveWithBFSPath(
    VoidCallback setState,
    VoidCallback showWinDialog,
  ) async {
    List<List<int>> path = getBFSPath();

    for (int i = 1; i < path.length; i++) {
      setState();

      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (winState()) {
      timer?.cancel();
      showWinDialog();
    }
  }

  //greedy

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

  //A*

  int? getAStarMove(bool useManhattan) {
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

      int h = useManhattan
          ? manhattanDistance(temp)
          : eculideanDistance(temp).toInt();
      int g = 1;

      int f = g + h;

      if (f < bestScore) {
        bestScore = f;
        bestMove = move;
      }
    }
    return bestMove; // clean placeholder
  }

  List<List<int>> getAstarPath(bool useManhattan) {
    List<List<int>> path = [];
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
    visited.add(start.toString());

    while (pq.isNotEmpty) {}
    return path;
  }

  //hint mechanism

  int? getHint() {
    switch (selectedSolver) {
      case SolverType.greedy:
        return getGreedyMove(false);
      case SolverType.bfs:
        return getBFSMove();
      case SolverType.aStar:
        return getAStarMove(false);
    }
  }

  //auto solving

  Future<void> autoSolve(
    VoidCallback setState,
    VoidCallback showWinDialog,
  ) async {
    visited.clear();

    if (selectedSolver == SolverType.bfs) {
      await solveWithBFSPath(setState, showWinDialog);
      return;
    }

    while (!winState()) {
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

      handleTap(hint,setState,showWinDialog);

      if (winState()) break;

      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  //helper functions

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

  bool winState() {
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return true;
  }

  void handleTap(int tileIndex, VoidCallback setState,VoidCallback showWinDialog) {
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
}
