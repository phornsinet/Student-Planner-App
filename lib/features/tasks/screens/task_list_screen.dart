import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/task_controller.dart';
import '../models/task_model.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskController _controller = TaskController();
  String _activeFilter = "All";

  @override
  void initState() {
    super.initState();
    _controller.loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9), // Light grey background from image
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
                        _buildMyTasksSection(),
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

  // 1. TOP HEADER (Image 4)
  Widget _buildHeader(String email) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.school, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Smart Study Planner", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(email, style: const TextStyle(color: Color(0xFF2563EB), fontSize: 13)),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => FirebaseAuth.instance.signOut(),
          icon: const Icon(Icons.logout, size: 16),
          label: const Text("Logout"),
          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF2563EB), side: const BorderSide(color: Color(0xFFE2E8F0))),
        ),
      ],
    );
  }

  // 2. MY TASKS SECTION (Image 4)
  Widget _buildMyTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("My Tasks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("${_controller.totalTasks} tasks in total", style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
        _buildFilterTabs(),
        const SizedBox(height: 16),
        _buildEmptyState(),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: ["All", "Pending", "Completed"].map((tab) {
          final isSelected = _activeFilter == tab;
          final count = tab == "All" ? _controller.totalTasks : tab == "Pending" ? _controller.pendingTasks : _controller.completedTasks;
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

  // 3. OVERALL PROGRESS SECTION (Image 3)
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

  // 4. BY CATEGORY SECTION (Image 3)
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

  // SHARED UI HELPER
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