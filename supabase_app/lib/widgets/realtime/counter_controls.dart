import 'package:flutter/material.dart';
import 'counter_button.dart';

class CounterControls extends StatelessWidget {
  final VoidCallback onDecrement;
  final VoidCallback onReset;
  final VoidCallback onIncrement;

  const CounterControls({
    super.key,
    required this.onDecrement,
    required this.onReset,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CounterButton(
          icon: Icons.remove,
          color: Colors.red,
          onPressed: onDecrement,
          label: 'Decrease',
        ),
        CounterButton(
          icon: Icons.refresh,
          color: Colors.orange,
          onPressed: onReset,
          label: 'Reset',
        ),
        CounterButton(
          icon: Icons.add,
          color: Colors.green,
          onPressed: onIncrement,
          label: 'Increase',
        ),
      ],
    );
  }
}