import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/services/auth_service.dart';
import 'package:todo_app/services/todo_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:todo_app/widgets/empty_state_widget.dart';
import 'package:todo_app/widgets/todo_card.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/services/google_calendar_service.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _editTitleController = TextEditingController();
  final _editDescriptionController = TextEditingController();
  DateTime? _selectedDeadline;
  DateTime? _editSelectedDeadline;
  String _filter = 'all';
  GoogleCalendarService? _calendarService;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<TodoService>().loadTodos();
    });
    _calendarService = GoogleCalendarService();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _editTitleController.dispose();
    _editDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleAddTodo() async {
    if (!_formKey.currentState!.validate()) return;
    final todoService = context.read<TodoService>();
    await todoService.addTodo(
      _titleController.text.trim(),
      _descriptionController.text.trim(),
      deadline: _selectedDeadline,
    );
    if (todoService.error == null) {
      _titleController.clear();
      _descriptionController.clear();
      _selectedDeadline = null;
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _showAddTodoDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Todo'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(_selectedDeadline == null
                        ? 'No deadline'
                        : 'Deadline: \\${_selectedDeadline!.toLocal().toString().split(' ')[0]}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDeadline = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _handleAddTodo,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEditTodo(String id, String currentTitle, String currentDescription, {DateTime? currentDeadline}) async {
    _editTitleController.text = currentTitle;
    _editDescriptionController.text = currentDescription;
    _editSelectedDeadline = currentDeadline;
    if (!_formKey.currentState!.validate()) return;
    final todoService = context.read<TodoService>();
    await todoService.editTodo(
      id,
      _editTitleController.text.trim(),
      _editDescriptionController.text.trim(),
      deadline: _editSelectedDeadline,
    );
    if (todoService.error == null) {
      _editTitleController.clear();
      _editDescriptionController.clear();
      _editSelectedDeadline = null;
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _showEditTodoDialog(Todo todo) async {
    _editTitleController.text = todo.title;
    _editDescriptionController.text = todo.description;
    _editSelectedDeadline = todo.deadline;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Todo'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _editTitleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _editDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(_editSelectedDeadline == null
                        ? 'No deadline'
                        : 'Deadline: \\${_editSelectedDeadline!.toLocal().toString().split(' ')[0]}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _editSelectedDeadline ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _editSelectedDeadline = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _handleEditTodo(
              todo.id,
              _editTitleController.text,
              _editDescriptionController.text,
              currentDeadline: _editSelectedDeadline,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todoService = context.watch<TodoService>();
    final authService = context.watch<AuthService>();
    final theme = Theme.of(context);

    List<Todo> filteredTodos = todoService.todos;
    if (_filter == 'done') {
      filteredTodos = filteredTodos.where((t) => t.isCompleted ?? false).toList();
    } else if (_filter == 'undone') {
      filteredTodos = filteredTodos.where((t) => !t.isCompleted).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
        actions: [
          if (authService.user != null && authService.user!.email != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.account_circle, size: 24),
                  const SizedBox(width: 4),
                  Text(
                    authService.user!.email!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: todoService.isLoading
          ? const Center(
              child: SpinKitThreeBounce(
                color: Colors.blue,
                size: 32,
              ),
            )
          : todoService.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        todoService.error!,
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          todoService.clearError();
                          todoService.loadTodos();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          const Text('Filter:'),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: _filter,
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('All')),
                              DropdownMenuItem(value: 'undone', child: Text('Undone')),
                              DropdownMenuItem(value: 'done', child: Text('Done')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _filter = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: filteredTodos.isEmpty
                          ? const EmptyStateWidget()
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredTodos.length,
                              itemBuilder: (context, index) {
                                final todo = filteredTodos[index];
                                return Column(
                                  children: [
                                    ToDoCard(
                                      todo: todo,
                                      onToggle: () => todoService.toggleTodoStatus(todo.id),
                                      onEdit: () => _showEditTodoDialog(todo),
                                      onDelete: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Todo'),
                                            content: const Text('Are you sure you want to delete this todo?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  todoService.deleteTodo(todo.id);
                                                  Navigator.pop(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: theme.colorScheme.error,
                                                ),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    if (todo.deadline != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.calendar_today),
                                          label: const Text('Add to Google Calendar'),
                                          onPressed: () async {
                                            final success = await _calendarService?.addEventToCalendar(
                                              title: todo.title,
                                              description: todo.description,
                                              start: todo.deadline,
                                            );
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(success == true
                                                    ? 'Event added to Google Calendar!'
                                                    : 'Failed to add event.'),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
} 