import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskCategory { assignments, exams, studySessions }

class TaskModel {
  final String id;
  final String title;
  final String description; // Added for your UI
  final DateTime dueDate;   // Added for your UI
  final TaskCategory category;
  bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    required this.category,
    this.isCompleted = false,
  });

  // 1. Convert Firestore Document to TaskModel
  factory TaskModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TaskModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      // Firestore stores dates as "Timestamp", so we convert it to DateTime
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      category: TaskCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TaskCategory.assignments,
      ),
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  // 2. Convert TaskModel to Map to save in Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate), // Convert DateTime back to Timestamp
      'category': category.name,
      'isCompleted': isCompleted,
    };
  }

  // Helper for UI display
  String get categoryName {
    switch (category) {
      case TaskCategory.assignments: return "Assignments";
      case TaskCategory.exams: return "Exams";
      case TaskCategory.studySessions: return "Study Sessions";
    }
  }
}