import 'package:flutter/material.dart';

// --- IMPORTS (Ensuring relative paths match your sidebar) ---
import '../../tasks/screens/task_list_screen.dart'; 
import '../../timer/screens/pomodoro_screen.dart'; 
import 'account_screen.dart';
import 'music_placeholder_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // The order of these screens MUST match the destinations below
  final List<Widget> _screens = [
    const TaskListScreen(),         // Index 0
    const PomodoroScreen(),         // Index 1
    const MusicPlaceholderScreen(), // Index 2
    const AccountScreen(),          // Index 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Soft background color for a modern feel (Slate-50)
      backgroundColor: const Color(0xFFF8FAFC), 
      
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      // Redesigned modern Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                indicatorColor: const Color(0xFF2563EB).withOpacity(0.1),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.w600, 
                      color: Color(0xFF2563EB)
                    );
                  }
                  return const TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.w500, 
                    color: Color(0xFF64748B)
                  );
                }),
              ),
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                backgroundColor: Colors.transparent,
                elevation: 0,
                height: 65,
                // These destinations match your screens list order exactly
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined, color: Color(0xFF64748B)),
                    selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF2563EB)),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.timer_outlined, color: Color(0xFF64748B)),
                    selectedIcon: Icon(Icons.timer_rounded, color: Color(0xFF2563EB)),
                    label: 'Timer',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.music_note_outlined, color: Color(0xFF64748B)),
                    selectedIcon: Icon(Icons.music_note_rounded, color: Color(0xFF2563EB)),
                    label: 'Music',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline, color: Color(0xFF64748B)),
                    selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF2563EB)),
                    label: 'Account',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}