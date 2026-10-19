import 'package:flutter/material.dart';

class CountdownTiles extends StatelessWidget {
  const CountdownTiles({super.key, required this.remaining});

  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final total = remaining.isNegative ? Duration.zero : remaining;
    return Row(
      children: [
        _Tile(value: total.inDays, label: 'zile'),
        const SizedBox(width: 6),
        _Tile(value: total.inHours.remainder(24), label: 'ore'),
        const SizedBox(width: 6),
        _Tile(value: total.inMinutes.remainder(60), label: 'min'),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x24FFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x4DFFFFFF)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value.toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Color(0xFFD3DAE6), fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
