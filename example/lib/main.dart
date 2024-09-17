import 'package:flutter/material.dart';
import 'package:webview_continer/webview_container.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebView Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WebViewExample(),
    );
  }
}

class WebViewExample extends StatelessWidget {
  const WebViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const WebViewContainer(
      url: 'https://flutter.dev',
      backgroundColor: Colors.black,
    );
  }
}
