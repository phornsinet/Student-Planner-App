import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added for user ID
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for fetching profile
import '../models/task_model.dart';
import '../data/task_repository.dart';

class TaskController extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();
  
  List<TaskModel> _tasks = [];
  bool _isLoading = true;

  // --- NEW PROFILE VARIABLES ---
  String? _userProfileBase64;
  String? get userProfileBase64 => _userProfileBase64;

  // Getters
  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  // --- NEW: LOAD USER PROFILE ---
  // Fetches the Base64 image string from the users collection
  Future<void> loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          _userProfileBase64 = doc.data()?['photoBase64'];
          notifyListeners(); // Refreshes the Dashboard header
        }
      } catch (e) {
        debugPrint("Error loading profile: $e");
      }
    }
  }

  // --- REAL-TIME TASK LISTENER ---
  void loadTasks() {
    _isLoading = true;
    notifyListeners();

    _repository.getTasksStream().listen((newList) {
      _tasks = newList;
      _isLoading = false;
      notifyListeners(); 
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
      id: '', 
      title: title,
      category: category,
      dueDate: dueDate,
      description: description,
      isCompleted: false,
    );

    await _repository.saveTask(newTask);
  }

  Future<void> toggleTaskStatus(TaskModel task) async {
    task.isCompleted = !task.isCompleted;
    await _repository.updateTask(task);
  }

  Future<void> deleteTask(String id) async {
    await _repository.removeTask(id);
  }
}