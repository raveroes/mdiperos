import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_app/models/todo.dart';

class TodoService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();
  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _error;

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTodos() async {
    if (_auth.currentUser == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('todos')
          .orderBy('createdAt', descending: true)
          .get();

      _todos = snapshot.docs
          .map((doc) => Todo.fromMap(doc.data()))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo(String title, String description, {DateTime? deadline}) async {
    if (_auth.currentUser == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final now = DateTime.now();
      final todo = Todo(
        id: _uuid.v4(),
        title: title,
        description: description,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
        userId: _auth.currentUser!.uid,
        deadline: deadline,
      );

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('todos')
          .doc(todo.id)
          .set(todo.toMap());

      _todos.insert(0, todo);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTodo(Todo todo) async {
    if (_auth.currentUser == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedTodo = todo.copyWith(
        updatedAt: DateTime.now(),
        deadline: todo.deadline,
      );

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('todos')
          .doc(todo.id)
          .update(updatedTodo.toMap());

      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = updatedTodo;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    if (_auth.currentUser == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('todos')
          .doc(id)
          .delete();

      _todos.removeWhere((todo) => todo.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTodoStatus(String id) async {
    if (_auth.currentUser == null) return;

    try {
      final todo = _todos.firstWhere((t) => t.id == id);
      final updatedTodo = todo.copyWith(
        isCompleted: !todo.isCompleted,
        updatedAt: DateTime.now(),
      );

      await updateTodo(updatedTodo);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> editTodo(String id, String newTitle, String newDescription, {DateTime? deadline}) async {
    if (_auth.currentUser == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final todo = _todos.firstWhere((t) => t.id == id);
      final updatedTodo = todo.copyWith(
        title: newTitle,
        description: newDescription,
        updatedAt: DateTime.now(),
        deadline: deadline ?? todo.deadline,
      );

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('todos')
          .doc(id)
          .update(updatedTodo.toMap());

      final index = _todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _todos[index] = updatedTodo;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}