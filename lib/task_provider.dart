// task_provider.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Task {
  final String description;
  final int? timerDuration; // in seconds, null means stopwatch mode

  Task({required this.description, this.timerDuration});

  // Factory constructor to create a Task from a Hive map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      description: map['description'] as String,
      timerDuration: map['timerDuration'] as int?,
    );
  }

  // Convert Task to a Hive-compatible map
  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'timerDuration': timerDuration,
    };
  }
}

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];
  int? _timerDurationInSeconds;

  // Public getter for the tasks
  List<Task> get tasks => _tasks;

  /// The duration in seconds. Null means stopwatch mode.
  int? get timerDuration => _timerDurationInSeconds;

  // Getter for the task at the top of the list
  Task? get currentTask {
    if (_tasks.isNotEmpty) {
      return _tasks.first;
    }
    return null;
  }

  // Adds a new task to the end of the list
  Future<void> addTask(String task) async {
    if (task.isNotEmpty) {
      final newTask = Task(description: task, timerDuration: _timerDurationInSeconds);
      _tasks.add(newTask);
      notifyListeners();

      final box = await Hive.openBox('tasksBox');
      await box.add(newTask.toMap());
    }
  }

  // Removes the first task (marks it as complete)
  Future<void> completeTask() async {
    if (_tasks.isNotEmpty) {
      _tasks.removeAt(0);
      notifyListeners();

      final box = await Hive.openBox('tasksBox');
      await box.clear();
      for (var task in _tasks) {
        await box.add(task.toMap());
      }
    }
  }

  /// Sets the timer duration.
  /// Pass null or 0 to enable stopwatch mode.
  void setTimerDuration(int? minutes) {
    if (minutes == null || minutes <= 0) {
      _timerDurationInSeconds = null;
    } else {
      _timerDurationInSeconds = minutes * 60;
    }
  }

  // Load tasks from Hive
  Future<void> loadTasksFromHive() async {
    final box = await Hive.openBox('tasksBox');
    _tasks.clear();
    for (var taskMap in box.values) {
      _tasks.add(Task.fromMap(Map<String, dynamic>.from(taskMap)));
    }
    notifyListeners();
  }

  // Save tasks to Hive (not strictly necessary as Hive auto-saves)
  Future<void> saveTasksToHive() async {
    final box = await Hive.openBox('tasksBox');
    await box.clear();
    for (var task in _tasks) {
      await box.add(task.toMap());
    }
  }
}
