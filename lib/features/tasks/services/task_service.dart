import '../models/task_model.dart';

class TaskService {
  // Temporary in-memory list (Used as a local cache)
  final List<TaskModel> _tasks = [];

  // --- UPDATED CREATE ---
  // Added description and dueDate to match the new TaskModel
  void addTask({
    required String title, 
    required TaskCategory category, 
    String description = "", 
    DateTime? dueDate,
  }) {
    final newTask = TaskModel(
      id: DateTime.now().toString(),
      title: title,
      category: category,
      description: description,
      dueDate: dueDate ?? DateTime.now(), // Default to today if null
      isCompleted: false,
    );
    _tasks.add(newTask);
  }

  // --- READ ---
  List<TaskModel> getAllTasks() => _tasks;

  List<TaskModel> getTasksByStatus(bool isCompleted) {
    return _tasks.where((task) => task.isCompleted == isCompleted).toList();
  }

  // --- UPDATE ---
  void toggleTaskStatus(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    }
  }

  // --- STATISTICS ---
  int get totalCount => _tasks.length;

  int get completedCount => _tasks.where((t) => t.isCompleted).length;

  int get pendingCount => totalCount - completedCount;

  double get completionRate {
    if (totalCount == 0) return 0.0;
    return completedCount / totalCount;
  }

  int getCategoryCount(TaskCategory category) {
    return _tasks.where((t) => t.category == category).length;
  }
}