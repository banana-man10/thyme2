// task_provider.dart

import 'package:flutter/material.dart';

class TaskProvider with ChangeNotifier {
  final List<String> _tasks = [];
  
  // This variable holds the duration
  int? _timerDurationInSeconds;

  // Public getter for the tasks
  List<String> get tasks => _tasks;

  // --- THIS IS THE GETTER THE ERROR IS ASKING FOR ---
  /// The duration in seconds. Null means stopwatch mode.
  int? get timerDuration => _timerDurationInSeconds;
  // --------------------------------------------------

  // Getter for the task at the top of the list
  String? get currentTask {
    if (_tasks.isNotEmpty) {
      return _tasks.first;
    }
    return null;
  }

  // Adds a new task to the end of the list
  void addTask(String task) {
    if (task.isNotEmpty) {
      _tasks.add(task);
      notifyListeners(); // Tell widgets to rebuild
    }
  }

  // Removes the first task (marks it as complete)
  void completeTask() {
    if (_tasks.isNotEmpty) {
      _tasks.removeAt(0);
      notifyListeners(); // Tell widgets to rebuild
    }
  }

  // --- THIS IS THE METHOD THE ERROR IS ASKING FOR ---
  /// Sets the timer duration.
  /// Pass null or 0 to enable stopwatch mode.
  void setTimerDuration(int? minutes) {
    if (minutes == null || minutes <= 0) {
      _timerDurationInSeconds = null;
    } else {
      _timerDurationInSeconds = minutes * 60;
    }
    // No notifyListeners() needed here
  }
  // ----------------------------------------------------
}