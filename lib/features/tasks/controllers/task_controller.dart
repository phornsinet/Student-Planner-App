import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../data/task_repository.dart';
// Note: If you have logic in TaskService, keep it, 
// but usually we can move that logic here to keep it simple.

class TaskController extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();
  
  List<TaskModel> _tasks = [];
  bool _isLoading = true;

  // Getters
  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  // --- REAL-TIME LISTENER ---

  void loadTasks() {
    _isLoading = true;
    notifyListeners();

    // We "listen" to the stream. Every time a task is added/deleted in Firebase,
    // this block of code runs automatically.
    _repository.getTasksStream().listen((newList) {
      _tasks = newList;
      _isLoading = false;
      notifyListeners(); // This refreshes your UI screens!
    }, onError: (error) {
      debugPrint("Firestore Error: $error");
      _isLoading = false;
      notifyListeners();
    });
  }

  // --- CALCULATED STATS ---

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((t) => t.isCompleted).length;
  int get pendingTasks => _tasks.where((t) => !t.isCompleted).length;
  
  double get progressPercent {
    if (_tasks.isEmpty) return 0.0;
    return completedTasks / totalTasks;
  }

  int getCategoryCount(TaskCategory category) {
    return _tasks.where((t) => t.category == category).length;
  }

  // --- ACTIONS ---

  Future<void> addTask({
    required String title, 
    required TaskCategory category, 
    required DateTime dueDate, 
    String description = ""
  }) async {
    final newTask = TaskModel(
      id: '', // Firestore will create this ID
      title: title,
      category: category,
      dueDate: dueDate,
      description: description,
      isCompleted: false,
    );

    await _repository.saveTask(newTask);
    // Notice: We don't need to manually add to _tasks. 
    // The Stream listener above will detect the new task and update the UI!
  }

  Future<void> toggleTaskStatus(TaskModel task) async {
    task.isCompleted = !task.isCompleted;
    await _repository.updateTask(task);
  }

  Future<void> deleteTask(String id) async {
    await _repository.removeTask(id);
  }
}