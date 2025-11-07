// focus_page.dart
// test so this git will actually register a change
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'task_provider.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  int _seconds = 0; // Will hold elapsed time OR remaining time
  Timer? _timer;
  bool _isAllDone = false;
  bool _isStopwatchMode = false;

  @override
  void initState() {
    super.initState();
    // Check if the list is already empty when the page loads
    if (context.read<TaskProvider>().currentTask == null) {
      setState(() {
        _isAllDone = true;
      });
    } else {
      // Set up the timer for the *first* task
      _resetTimerForNextTask();
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Important: cancel timer to prevent memory leaks
    super.dispose();
  }

  /// Resets the timer based on the provider's settings.
  void _resetTimerForNextTask() {
    _timer?.cancel();

    // Get the duration from the provider
    final duration = context.read<TaskProvider>().timerDuration;

    if (duration == null) {
      // Stopwatch mode
      setState(() {
        _isStopwatchMode = true;
        _seconds = 0;
      });
    } else {
      // Countdown mode
      setState(() {
        _isStopwatchMode = false;
        _seconds = duration;
      });
    }

    // Start the timer (which now has new logic)
    _startTimer();
  }

  void _addTenMinutes() {
    if (!_isStopwatchMode) {
      windowManager.setAlwaysOnTop(true);
      windowManager.setSize(const Size(200, 255), animate: true);
      windowManager.setAlignment(Alignment.bottomRight, animate: true);
      setState(() {
        _seconds = 600; // Set to 10 minutes
      });
      _startTimer(); // Restart the timer
    }
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isStopwatchMode) {
        // --- STOPWATCH LOGIC ---
        setState(() {
          _seconds++;
        });
      } else {
        // --- COUNTDOWN LOGIC ---
        if (_seconds > 0) {
          setState(() {
            _seconds--;
          });
        } else {
          timer.cancel(); // Stop timer at 0
          windowManager.center(animate: true);
          windowManager.setSize(const Size(500, 300), animate: true);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Time is up!'),
              actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _completeTask();
            },
            child: const Text('Next task'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addTenMinutes();
            },
            child: const Text('10 more minutes'),
          ),
              ],
            ),
          );
        }
      }
    });
  }

  String get _formattedTime {
    final int minutes = _seconds ~/ 60;
    final int seconds = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _completeTask() {
    final provider = context.read<TaskProvider>();
    provider.completeTask(); // Remove current task

    if (provider.currentTask == null) {
      // No tasks left!
      _timer?.cancel();
      setState(() {
        _isAllDone = true;
      });
    } else {
      // More tasks, just restart the timer
      _resetTimerForNextTask();
    }
  }

  void _goBackToList() {
    // This will pop the route, triggering the
    // logic in list_page.dart to resize the window.
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          // --- PAGE CONTENT ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isAllDone ? _buildAllDoneView() : _buildTaskView(),
            ),
          ),
        ],
      ),
    );
  }

  // --- View for "All Done" ---
  Widget _buildAllDoneView() {
    // Resize window when showing All Done view (non-blocking)
    windowManager.setSize(const Size(500, 300));
    windowManager.center();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'All done! Great job completing your tasks!',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _goBackToList,
            child: const Text('Back to List'),
          ),
        ],
      ),
    );
  }

  // --- View for showing a task and timer ---
  Widget _buildTaskView() {
    // Use Consumer here so the task text updates
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Timer
            Text(
              _formattedTime,
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),



            
            // Current Task
            Flexible(
              child: Center( // This vertically centers the text.
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // <-- SCROLLS HORIZONTALLY
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    provider.currentTask ?? '', // Show current task
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w300),
                    maxLines: 1,     // <-- KEEPS IT ON ONE LINE
                    softWrap: false, // <-- PREVENTS WRAPPING
                  ),
                ),
              ),
            ),

            // Checkmark Button
            IconButton.filled(
              onPressed: _completeTask,
              icon: const Icon(Icons.check),
              iconSize: 50,
              style: IconButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}