import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';

class TimerController extends ChangeNotifier {
  Timer? _timer;
  
  int _totalSessionSeconds = 25 * 60; 
  int _secondsRemaining = 25 * 60;    
  bool _isActive = false;

  final AudioPlayer _audioPlayer = AudioPlayer(); 

  int totalFocusMinutesToday = 0;
  int dailyGoalMinutes = 120; 

  int get secondsRemaining => _secondsRemaining;
  int get totalSessionSeconds => _totalSessionSeconds; 
  bool get isActive => _isActive;

  String get timerString {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }


  Future<void> _playStartSound() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/start_timer.mp3'));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  // NEW: Helper to stop the sound
  Future<void> _stopSound() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint("Error stopping sound: $e");
    }
  }

  // --- TIMER LOGIC ---

  void setSessionTime(int minutes) {
    _timer?.cancel();
    _stopSound(); // Stop sound if session duration is changed
    _isActive = false;
    _totalSessionSeconds = minutes * 60;
    _secondsRemaining = _totalSessionSeconds;
    notifyListeners();
  }

  void updateDailyGoal(int newGoal) {
    dailyGoalMinutes = newGoal;
    notifyListeners();
  }

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
      // 1. PAUSE: Cancel timer and STOP sound
      _timer?.cancel();
      _stopSound(); 
    } else {
      // 2. START: Play sound and start timer
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
    _stopSound(); // STOP sound when user resets
    _isActive = false;
    _secondsRemaining = _totalSessionSeconds;
    notifyListeners();
  }

  Future<void> _completeSession() async {
    _timer?.cancel();
    _stopSound(); // STOP sound when session finishes
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
    _audioPlayer.dispose(); 
    super.dispose();
  }
}