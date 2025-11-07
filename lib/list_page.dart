import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'task_provider.dart';
import 'main.dart'; // To get kDefaultSize
import 'custom_title_bar.dart';
import 'dart:io';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}
    
class _ListPageState extends State<ListPage> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  void _addTask() {
    // Use context.read inside a function to call a method
    context.read<TaskProvider>().addTask(_taskController.text);
    _taskController.clear();
  }

  Future<void> _startFocusSession() async {
    final provider = context.read<TaskProvider>();
    final int? durationInMinutes = int.tryParse(_durationController.text);
    provider.setTimerDuration(durationInMinutes);

    if (provider.tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('I might be crazy, but I think you need to add something to your list first...'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 1. Resize and move the window
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setSize(const Size(200, 255), animate: true);
    await windowManager.setAlignment(Alignment.bottomRight, animate: true);

    // 2. Navigate to the focus page
    // We listen for when it's "popped" (returns)
    await Navigator.pushNamed(context, '/focus');

    // 3. This code runs AFTER returning from the focus page
    await windowManager.setAlwaysOnTop(false);
    await windowManager.setSize(kDefaultSize, animate: true);
    await windowManager.center(animate: true);

    // 4. Show "All done!" message if tasks are empty
    if (provider.tasks.isEmpty && mounted) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          
          content: Text('All done! Great job completing your tasks!'),
          backgroundColor: Color.fromARGB(255, 32, 97, 97),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomTitleBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            
            if (Platform.isMacOS) ...[
              const Text(
                'Note: We cannot test bugs on MacOS because they are 4000 thousand dollars. If you see a bug on Mac, please report it on github!',
                style: TextStyle(color: Colors.orangeAccent),
              ),
              const SizedBox(height: 10),
            ],



            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a new task...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Timer Duration (in minutes)',
                      hintText: 'blank for stopwatch',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: _addTask,
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // --- Task List ---
            Expanded(
              child: Consumer<TaskProvider>(
                builder: (context, provider, child) {
                  if (provider.tasks.isEmpty) {
                    return const Center(
                      child: Text(
                        'No tasks yet. Add some!',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: provider.tasks.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(provider.tasks[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            // --- Start Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startFocusSession,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text(
                  'Start Focus Session',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}