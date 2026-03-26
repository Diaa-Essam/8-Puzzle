import 'package:flutter/material.dart';

class TileWidget extends StatelessWidget {
  final int value;
  final VoidCallback? onTap;
  final bool isMovable;

  const TileWidget({
    super.key,
    required this.value,
    required this.onTap,
    required this.isMovable,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: value == 0 ? null : onTap,
      child: Transform.scale(
        scale: isMovable ? 1.05 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 80,
          height: 80,
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            boxShadow: value == 0
                ? []
                : isMovable
                ? const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 4,
                    ),
                  ],
            borderRadius: BorderRadius.circular(12),
            color: value == 0
                ? Colors.transparent
                : isMovable
                ? Colors.orange
                : Colors.brown,
            border: Border.all(),
          ),
          child: Center(
            child: Text(
              value == 0 ? "" : "$value",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
