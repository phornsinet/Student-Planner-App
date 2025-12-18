import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Get the path to the current user's task collection
  // This ensures data privacy: users/{userId}/tasks/
  CollectionReference get _taskRef {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");
    return _db.collection('users').doc(user.uid).collection('tasks');
  }

  // CREATE: Save a new task
  Future<void> saveTask(TaskModel task) async {
    await _taskRef.add(task.toMap());
  }

  // READ: Get tasks in real-time
  // Using a Stream means the UI updates instantly when the database changes
  Stream<List<TaskModel>> getTasksStream() {
    return _taskRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // UPDATE: Update task (like marking it completed)
  Future<void> updateTask(TaskModel task) async {
    await _taskRef.doc(task.id).update(task.toMap());
  }

  // DELETE: Remove a task
  Future<void> removeTask(String id) async {
    await _taskRef.doc(id).delete();
  }
}