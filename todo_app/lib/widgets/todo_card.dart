import 'package:flutter/material.dart';
import 'package:todo_app/models/todo.dart';

class ToDoCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ToDoCard({
    super.key,
    required this.todo,
    this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(todo.description),
            if (todo.deadline != null)
              Text(
                'Deadline: \\${todo.deadline!.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
          ],
        ),
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) => onToggle?.call(),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
} 