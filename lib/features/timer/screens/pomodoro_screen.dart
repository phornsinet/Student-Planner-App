import 'package:flutter/material.dart';
import 'package:student_planner_app/features/timer/controllers/timer_controller.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  final TimerController _timerController = TimerController();

  @override
  void dispose() {
    _timerController.dispose(); 
    super.dispose();
  }

  // DIALOG TO EDIT TIME
  void _showEditTimeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Focus Duration"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [15, 25, 45, 60].map((mins) {
            return ListTile(
              title: Text("$mins Minutes"),
              leading: const Icon(Icons.timer),
              onTap: () {
                _timerController.setSessionTime(mins);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Focus Timer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2563EB),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 60),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: ListenableBuilder(
              listenable: _timerController,
              builder: (context, _) {
                return Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 220,
                          height: 220,
                          child: CircularProgressIndicator(
                            // Updated to use the dynamic total session time
                            value: _timerController.secondsRemaining / _timerController.totalSessionSeconds,
                            strokeWidth: 10,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _timerController.timerString,
                              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            // ADDED: EDIT BUTTON
                            GestureDetector(
                              onTap: _showEditTimeDialog,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit, size: 12, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text("Change Time", style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _timerController.toggleTimer,
                          icon: Icon(_timerController.isActive ? Icons.pause : Icons.play_arrow),
                          label: Text(_timerController.isActive ? "Pause" : "Start Focus"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: _timerController.resetTimer,
                          icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          
          const Spacer(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Icon(Icons.lightbulb_outline, color: Color(0xFF2563EB), size: 32),
                SizedBox(height: 12),
                Text(
                  "The Pomodoro Technique",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  "Focus for 25 minutes, then take a 5-minute break. This keeps your brain fresh!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}