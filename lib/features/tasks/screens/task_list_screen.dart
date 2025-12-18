import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Needed for date formatting
import '../controllers/task_controller.dart';
import '../models/task_model.dart';
import 'add_task_screen.dart';
import 'edit_profile_screen.dart';
import 'dart:convert';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskController _controller = TaskController();
  // Using string for filter states to match your UI tabs
  String _activeFilter = "All";

 @override
void initState() {
  super.initState();
  _controller.loadTasks();      // Loads your task list
  _controller.loadUserProfile(); // Loads your Base64 photo from Firestore
}

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // ListenableBuilder rebuilds the subtree whenever the controller notifies changes
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          body: SafeArea(
            child: _controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(user?.email ?? "User"),
                        const SizedBox(height: 24),
                        _buildMyTasksSection(), // This section contains the list
                        const SizedBox(height: 24),
                        _buildOverallProgress(),
                        const SizedBox(height: 24),
                        _buildByCategory(),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

 Widget _buildHeader(String email) {
  final user = FirebaseAuth.instance.currentUser;

  return Row(
    children: [
      // 1. PROFILE IMAGE SECTION
      CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFF2563EB),
        // Checks if the controller has the Base64 photo string we saved to Firestore
        child: _controller.userProfileBase64 != null && _controller.userProfileBase64!.isNotEmpty
            ? ClipOval(
                child: Image.memory(
                  base64Decode(_controller.userProfileBase64!),
                  fit: BoxFit.cover,
                  width: 48,
                  height: 48,
                  errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.person, color: Colors.white),
                ),
              )
            : const Icon(Icons.school, color: Colors.white, size: 24),
      ),
      const SizedBox(width: 12),
      
      // 2. TEXT SECTION (Title & Email)
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.displayName ?? "Smart Study Planner", 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)
            ),
            Text(
              email, 
              style: const TextStyle(color: Color(0xFF2563EB), fontSize: 11, overflow: TextOverflow.ellipsis)
            ),
          ],
        ),
      ),

      // 3. EDIT PROFILE BUTTON
      IconButton(
        icon: const Icon(Icons.edit_note, color: Color(0xFF2563EB)),
        tooltip: "Edit Profile",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
          );
        },
      ),

      // 4. LOGOUT BUTTON
      OutlinedButton(
        onPressed: () => FirebaseAuth.instance.signOut(),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Row(
          children: [
            Icon(Icons.logout, size: 14, color: Color(0xFF2563EB)),
            SizedBox(width: 4),
            Text("Logout", style: TextStyle(fontSize: 12, color: Color(0xFF2563EB))),
          ],
        ),
      ),
    ],
  );
}

  // === UPDATED SECTION: MY TASKS ===
  Widget _buildMyTasksSection() {
    // 1. Filter tasks based on the selected tab
    final filteredList = _controller.tasks.where((task) {
      if (_activeFilter == "Pending") return !task.isCompleted;
      if (_activeFilter == "Completed") return task.isCompleted;
      return true; // "All"
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title and Add Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("My Tasks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // Real-time count update
                Text("${filteredList.length} tasks listed", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => showDialog(context: context, builder: (_) => AddTaskPopup(controller: _controller)),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add Task"),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Filter Tabs
        _buildFilterTabs(),
        const SizedBox(height: 16),
        
        // The Task List or Empty State
        filteredList.isEmpty 
            ? _buildEmptyState() 
            : _buildTaskList(filteredList),
      ],
    );
  }

  // === NEW CODE: THE TASK LIST VIEW ===
  Widget _buildTaskList(List<TaskModel> tasks) {
    return ListView.separated(
      shrinkWrap: true, // Important for being inside SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildTaskCard(tasks[index]);
      },
    );
  }

  // === NEW CODE: THE INDIVIDUAL TASK CARD ===
  Widget _buildTaskCard(TaskModel task) {
    // Determine colors based on category
    final categoryColor = _getCategoryColor(task.category);
    final categoryIcon = _getCategoryIcon(task.category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Checkbox, Title, Category Badge
          Row(
            children: [
              // Custom Checkbox looking style
              InkWell(
                onTap: () => _controller.toggleTaskStatus(task),
                child: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: task.isCompleted ? const Color(0xFF2563EB) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: task.isCompleted ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1), width: 2)
                  ),
                  child: task.isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                ),
              ),
              const SizedBox(width: 12),
              // Title
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted ? Colors.grey : Colors.black,
                  ),
                ),
              ),
              // Category Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(categoryIcon, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      task.categoryName,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Row 2: Description (if exists)
          if (task.description.isNotEmpty) ...[
             const SizedBox(height: 8),
             Padding(
               padding: const EdgeInsets.only(left: 36.0), // Indent to align with title
               child: Text(
                 task.description,
                 style: const TextStyle(color: Colors.grey, fontSize: 13),
                 maxLines: 2,
                 overflow: TextOverflow.ellipsis,
               ),
             ),
          ],

          const SizedBox(height: 16),
          // Row 3: Date and Actions
          Row(
            children: [
              const SizedBox(width: 36), // Indent
              // Date Icon and Text
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                child: Icon(Icons.calendar_today_outlined, size: 14, color: Colors.blue[700]),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMM dd, yyyy').format(task.dueDate),
                style: TextStyle(color: Colors.blue[700], fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              // Edit Icon (Placeholder action)
              Icon(Icons.edit_outlined, size: 18, color: Colors.blue[600]),
              const SizedBox(width: 16),
              // Delete Icon
              InkWell(
                onTap: () => _controller.deleteTask(task.id),
                child: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
              ),
            ],
          )
        ],
      ),
    );
  }

  // === NEW HELPER FUNCTIONS FOR COLORS/ICONS ===
  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.assignments: return const Color(0xFF2563EB); // Blue
      case TaskCategory.exams: return const Color(0xFFE11D48);       // Red
      case TaskCategory.studySessions: return const Color(0xFF059669); // Green
    }
  }

  IconData _getCategoryIcon(TaskCategory category) {
     switch (category) {
      case TaskCategory.assignments: return Icons.description;
      case TaskCategory.exams: return Icons.school;
      case TaskCategory.studySessions: return Icons.menu_book;
    }
  }

  // ... (Keep _buildFilterTabs, _buildEmptyState, _buildOverallProgress, 
  //      _buildStatusBox, _buildByCategory, _categoryRow, _buildSectionHeader unchanged) ...
  
  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: ["All", "Pending", "Completed"].map((tab) {
          final isSelected = _activeFilter == tab;
          // Dynamic counts for tabs
          int count = 0;
          if(tab == "All") count = _controller.totalTasks;
          if(tab == "Pending") count = _controller.pendingTasks;
          if(tab == "Completed") count = _controller.completedTasks;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeFilter = tab),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: isSelected ? const Color(0xFF2563EB) : Colors.transparent, borderRadius: BorderRadius.circular(6)),
                child: Center(child: Text("$tab ($count)", style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w500, fontSize: 13))),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.2), style: BorderStyle.solid)),
      child: Column(
        children: [
          CircleAvatar(backgroundColor: const Color(0xFF2563EB).withOpacity(0.1), child: const Icon(Icons.add, color: Color(0xFF2563EB))),
          const SizedBox(height: 12),
          const Text("No tasks yet. Click \"Add Task\" to get started!", style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildOverallProgress() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildSectionHeader("Overall Progress", Icons.check_circle_outline),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Completion Rate", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    Text("${(_controller.progressPercent * 100).toInt()}%", style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(value: _controller.progressPercent, minHeight: 8, backgroundColor: const Color(0xFFE2E8F0), color: const Color(0xFF2563EB)),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildStatusBox("Completed", _controller.completedTasks, const Color(0xFFF0FDF4), const Color(0xFF16A34A), Icons.check_circle),
                    const SizedBox(width: 12),
                    _buildStatusBox("Pending", _controller.pendingTasks, const Color(0xFFFFF7ED), const Color(0xFFEA580C), Icons.access_time),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBox(String label, int count, Color bg, Color accent, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: accent.withOpacity(0.2))),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.white, size: 16)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w500)),
                Text("$count", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accent)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildByCategory() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildSectionHeader("By Category", Icons.book_outlined),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _categoryRow("Assignments", _controller.getCategoryCount(TaskCategory.assignments), const Color(0xFF2563EB), Icons.description),
                const SizedBox(height: 12),
                _categoryRow("Exams", _controller.getCategoryCount(TaskCategory.exams), const Color(0xFFE11D48), Icons.school),
                const SizedBox(height: 12),
                _categoryRow("Study Sessions", _controller.getCategoryCount(TaskCategory.studySessions), const Color(0xFF059669), Icons.menu_book),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryRow(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.1))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.white, size: 18)),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text("$count", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Color(0xFF2563EB), borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}