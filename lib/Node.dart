class Node {
  final List<int> state;
  final Node? parent;
  final int cost;
  final double fScore;

  Node({
    required this.state,
    this.parent,
    required this.cost,
    required this.fScore,
  });
}
