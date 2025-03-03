import 'package:flutter/material.dart';

class InfoButton extends StatelessWidget {
  final String label;
  final String feedback;
  final VoidCallback onPressed;

  const InfoButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 8),
          Text(feedback),
        ],
      ),
    );
  }
}