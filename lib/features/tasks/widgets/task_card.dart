import 'package:flutter/material.dart';

// --- Constants ---
const Color primaryBlue = Color(0xFF1976D2);
const Color pendingOrange = Color(0xFFFF9800);

class TaskCard extends StatelessWidget {
  final String title;
  final String? description; // added
  final String category;
  final String dueDate;
  final bool isCompleted;

  const TaskCard({
    super.key,
    required this.title,
    this.description, // added
    required this.category,
    required this.dueDate,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? Colors.green : primaryBlue,
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration:
                isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 5),
                Text(dueDate),
                const SizedBox(width: 10),
                // Reusing the priority chip concept for category
                _buildCategoryChip(category),
              ],
            ),
            if (description != null) const SizedBox(height: 8),
            if (description != null)
              Text(
                description!,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  decoration:
                      isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                ),
              ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {
          // TODO: Navigate to TaskDetailScreen
        },
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    Color color;
    switch (category) {
      case 'Assignment':
        color = primaryBlue;
        break;
      case 'Exam':
        color = Colors.redAccent;
        break;
      default:
        color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
