import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ganti path asset di bawah dengan asset SVG/png yang diunduh
          SvgPicture.asset(
            'assets/empty_task.svg',
            height: 120,
            width: 120,
            placeholderBuilder: (context) => const Icon(Icons.task_alt, size: 64, color: Colors.blueGrey),
          ),
          const SizedBox(height: 24),
          Text(
            'No todos yet',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new todo to get started',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
} 