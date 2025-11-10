import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'list_page.dart';
import 'focus_page.dart';
import 'package:hive/hive.dart';
import 'task_provider.dart';


// Store the original window size
const Size kDefaultSize = Size(500, 700);

void main() async {
  // Ensure Flutter and WindowManager are initialized
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  final TaskProvider taskProvider = TaskProvider();
  await taskProvider.loadTasksFromHive();
  print('Loaded tasks from CSV: ${taskProvider.tasks}');

  

  // Set up the initial window properties
    WindowOptions windowOptions = const WindowOptions(
    size: kDefaultSize,
    center: true,
    title: 'Thyme',
    titleBarStyle: TitleBarStyle.hidden
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(MyApp(taskProvider: taskProvider));
}

class MyApp extends StatelessWidget {
  final TaskProvider taskProvider;

  const MyApp({super.key, required this.taskProvider});

  @override
  Widget build(BuildContext context) {
    // Provide the preloaded TaskProvider instance to the whole app
    return ChangeNotifierProvider.value(
      value: taskProvider, // Use the preloaded TaskProvider instance
      child: MaterialApp(
        title: 'Thyme',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF22272e),
          primaryColor: Colors.blueAccent,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const ListPage(),
          '/focus': (context) => const FocusPage(),
        },
      ),
    );
  }
}