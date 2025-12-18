import 'package:flutter/material.dart';

// --- IMPORTS ---
import '../../tasks/screens/task_list_screen.dart'; 
import '../../timer/screens/pomodoro_screen.dart'; 
import 'account_screen.dart';
// 1. CHANGE THIS IMPORT (Ensure you create quote_screen.dart)
import 'quote_screen.dart'; 

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // 2. UPDATE THE SCREEN LIST
  final List<Widget> _screens = [
    const TaskListScreen(),         // Index 0
    const PomodoroScreen(),         // Index 1
    const QuoteScreen(),            // Index 2 (Changed from Music)
    const AccountScreen(),          // Index 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), 
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
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
                    return const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2563EB));
                  }
                  return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B));
                }),
              ),
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                backgroundColor: Colors.transparent,
                elevation: 0,
                height: 65,
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
                  // 3. UPDATE THE QUOTES DESTINATION
                  NavigationDestination(
                    icon: Icon(Icons.lightbulb_outline, color: Color(0xFF64748B)),
                    selectedIcon: Icon(Icons.lightbulb_rounded, color: Color(0xFF2563EB)),
                    label: 'Quotes',
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