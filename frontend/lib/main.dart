import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:ui_web' as ui_web if (dart.library.html) 'dart:ui_web.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';

//Global video element
late html.VideoElement globalVideoElement;

void main() {
  print('[MAIN] Starting BlackboardAI Flutter App');
  
// Create global video element ONCE
  print('[MAIN] Creating global video element');
  globalVideoElement = html.VideoElement();
  globalVideoElement.controls = true;
  globalVideoElement.autoplay = false;
  globalVideoElement.style.width = '100%';
  globalVideoElement.style.height = '100%';
  globalVideoElement.style.objectFit = 'contain';
  globalVideoElement.style.backgroundColor = '#000000';
  
  print('[MAIN] ✓ Global video element created');
  
  // Register platform view factory with the global element
  print('[MAIN] Registering HTML5 video platform view factory');
  
  ui_web.platformViewRegistry.registerViewFactory(
    'html5-video-player',
    (int viewId) {
      print('[MAIN] Platform view factory called (viewId: $viewId)');
      print('[MAIN] Returning global video element');
      return globalVideoElement;
    },
  );
  
  print('[MAIN] ✓ Platform view factory registered successfully');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('[MAIN] Building MyApp widget');
    
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) {
            print('[MAIN] Creating ApiService provider');
            return ApiService();
          },
        ),
      ],
      child: MaterialApp(
        title: 'BlackboardAI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[50],
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.light,
        home: const HomeScreen(),
      ),
    );
  }
}
