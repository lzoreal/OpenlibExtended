// Flutter imports:
import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  const TitleText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
      child: Text(
        text,
        style: theme.textTheme.headlineMedium,
      ),
    );
  }
}
