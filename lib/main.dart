import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'list_page.dart';
import 'focus_page.dart';
import 'task_provider.dart';

// Store the original window size
const Size kDefaultSize = Size(500, 700);

void main() async {
  // Ensure Flutter and WindowManager are initialized
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the TaskList state to the whole app
    return ChangeNotifierProvider(
      create: (context) => TaskProvider(),
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