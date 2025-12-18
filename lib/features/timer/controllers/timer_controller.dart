import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart'; // NEW IMPORT

class TimerController extends ChangeNotifier {
  Timer? _timer;
  
  // Variables for the countdown
  int _totalSessionSeconds = 25 * 60; 
  int _secondsRemaining = 25 * 60;    
  bool _isActive = false;

  // Sound player instance
  final AudioPlayer _audioPlayer = AudioPlayer(); 

  // Focus Stats variables
  int totalFocusMinutesToday = 0;
  int dailyGoalMinutes = 120; 

  // Getters
  int get secondsRemaining => _secondsRemaining;
  int get totalSessionSeconds => _totalSessionSeconds; 
  bool get isActive => _isActive;

  String get timerString {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // SOUND LOGIC: Play sound when the timer starts
  Future<void> _playStartSound() async {
    try {
      // Audioplayers 6.x uses AssetSource for files in the assets folder
      await _audioPlayer.play(AssetSource('sounds/start_timer.mp3'));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  // Update session time (e.g., change to 15, 45, or 60 mins)
  void setSessionTime(int minutes) {
    _timer?.cancel();
    _isActive = false;
    _totalSessionSeconds = minutes * 60;
    _secondsRemaining = _totalSessionSeconds;
    notifyListeners();
  }

  // Update the daily goal (e.g., change 120 mins to 200 mins)
  void updateDailyGoal(int newGoal) {
    dailyGoalMinutes = newGoal;
    notifyListeners();
  }

  // Load today's focus minutes from Firebase
  Future<void> loadDailyFocusTime() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('focus_sessions')
          .where('userId', isEqualTo: user.uid)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .get();

      int total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['durationMinutes'] as int? ?? 0);
      }

      totalFocusMinutesToday = total;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading focus stats: $e");
    }
  }

  void toggleTimer() {
    if (_isActive) {
      _timer?.cancel();
    } else {
      // PLAY SOUND when starting
      _playStartSound(); 

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          notifyListeners();
        } else {
          _completeSession();
        }
      });
    }
    _isActive = !_isActive;
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _isActive = false;
    _secondsRemaining = _totalSessionSeconds;
    notifyListeners();
  }

  Future<void> _completeSession() async {
    _timer?.cancel();
    _isActive = false;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      int minutesCompleted = _totalSessionSeconds ~/ 60;

      await FirebaseFirestore.instance.collection('focus_sessions').add({
        'userId': user.uid,
        'durationMinutes': minutesCompleted,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await loadDailyFocusTime();
    }
    
    _secondsRemaining = _totalSessionSeconds;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose(); // Always dispose the player to save memory
    super.dispose();
  }
}