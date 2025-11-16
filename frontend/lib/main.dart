import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:ui_web' as ui_web if (dart.library.html) 'dart:ui_web.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';

void main() {
  print('[MAIN] Starting BlackboardAI Flutter App');
  
  // CRITICAL: Register HTML5 video player BEFORE running app
  print('[MAIN] Registering HTML5 video platform view factory');
  

    ui_web.platformViewRegistry.registerViewFactory(
    'html5-video-player',
    (int viewId) {
      final video = html.VideoElement();
      video.controls = true;
      video.autoplay = false;
      video.style.width = '100%';
      video.style.height = '100%';
      video.style.objectFit = 'contain';
      video.style.backgroundColor = '#000000';
      return video;
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