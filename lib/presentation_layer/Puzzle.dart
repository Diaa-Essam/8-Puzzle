import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myapp/controller_layer/AgentsController.dart';
import 'package:myapp/controller_layer/SolverType.dart';
import 'package:myapp/presentation_layer/TileWidget.dart';

class Puzzle extends StatefulWidget {
  const Puzzle({super.key});

  @override
  State<Puzzle> createState() => _PuzzleState();
}

class _PuzzleState extends State<Puzzle> {
  final Agentscontroller _controller = Agentscontroller();

  @override
  void initState() {
    _controller.shuffle();
    super.initState();
  }

  @override
  void dispose() {
    _controller.timer?.cancel();
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
                    "Moves: ${_controller.moves}\nTimer: ${formatTime(_controller.time)}",
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
                      int emptyIndex = _controller.tiles.indexOf(0);
                      bool isMovable = _controller.validMove(index, emptyIndex);
                      return TileWidget(
                        value: _controller.tiles[index],
                        onTap: isMovable
                            ? () {
                                if (_controller.moves == 0) {
                                  _startCountUp();
                                }
                                _controller.handleTap(
                                  index,
                                  () => setState(() {}),
                                  showWinDialog,
                                );
                              }
                            : null,
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
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
                                      _controller.isSolving = false;
                                    });

                                    Future.delayed(
                                      const Duration(milliseconds: 50),
                                      () {
                                        setState(() {
                                          _controller.isSolving = false;
                                          _controller.shuffle();
                                          _startCountUp();
                                        });
                                      },
                                    );
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
                    const SizedBox(width: 5),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          int? hint = _controller.getHint();
                          if (hint != null) {
                            if (_controller.moves == 0) _startCountUp();
                            _controller.handleTap(
                              hint,
                              () => setState(() {}),
                              showWinDialog,
                            );
                          }
                        },
                        child: const Text("Hint"),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          await _controller.autoSolve(
                            () => setState(() {}),
                            showWinDialog,
                          );
                        },
                        child: const Text(
                          "Auto Solver",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Solver: "),
                    DropdownButton<SolverType>(
                      value: _controller.selectedSolver,
                      items: const [
                        DropdownMenuItem(
                          value: SolverType.bfs,
                          child: Text("BFS"),
                        ),
                        DropdownMenuItem(
                          value: SolverType.dfs,
                          child: Text("DFS"),
                        ),
                        DropdownMenuItem(
                          value: SolverType.greedy,
                          child: Text("Greedy"),
                        ),

                        DropdownMenuItem(
                          value: SolverType.aStar,
                          child: Text("A*"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _controller.selectedSolver = value!;
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
                      value: _controller.useManhattan,
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
                          _controller.useManhattan = value!;
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

  // fully UI
  void _startCountUp() {
    _controller.timer?.cancel();

    _controller.timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _controller.time++;
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

  void showWinDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("You Win 🎉"),
        content: Text(
          "Solver: ${_controller.selectedSolver.name}\n"
          "Moves: ${_controller.moves}\n"
          "Time: ${formatTime(_controller.time)}\n\n"
          "Nodes Expanded: ${_controller.nodesExpanded}\n"
          "Path Length: ${_controller.pathLength}\n"
          "Execution Time: ${_controller.executionTime}ms\n",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _controller.shuffle();
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
