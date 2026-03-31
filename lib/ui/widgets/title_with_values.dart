import 'package:flutter/material.dart';

class TitleWithValue extends StatelessWidget {
  final String title;
  final String value;

  const TitleWithValue({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w100),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        )
      ],
    );
  }
}
