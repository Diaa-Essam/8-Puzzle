class Node {
  final List<int> state;
  final Node? parent;
  final int cost;

  Node({required this.state, this.parent, required this.cost});
}
