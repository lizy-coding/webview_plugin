import 'package:flutter/material.dart';
import 'dart:io';
import '../platforms/android/android_webview.dart';
import '../platforms/windows/windows_webview.dart';

/// Main container widget that automatically selects the appropriate
/// platform-specific implementation.
///
/// This widget provides backward compatibility with the old API
/// while using the new optimized internal structure.
class WebViewContainer extends StatelessWidget {
  /// The URL to load in the WebView
  final String url;
  
  /// Whether to show the navigation bar
  final bool showNavigationBar;
  
  /// Custom AppBar to use instead of the default one
  final PreferredSizeWidget? appBar;
  
  /// Background color for the WebView
  final Color backgroundColor;

  /// Creates a WebView container with the specified settings.
  const WebViewContainer({
    Key? key,
    required this.url,
    this.showNavigationBar = true,
    this.appBar,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Select platform-specific implementation
    if (Platform.isAndroid) {
      return AndroidWebView(
        url: url,
        showNavigationBar: showNavigationBar,
        appBar: appBar,
        backgroundColor: backgroundColor,
      );
    } else if (Platform.isWindows) {
      return WindowsWebView(
        url: url,
        showNavigationBar: showNavigationBar,
        appBar: appBar,
        backgroundColor: backgroundColor,
      );
    } else {
      // Fallback for unsupported platforms
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              '不支持当前平台',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('WebView 插件目前仅支持 Android 和 Windows 平台'),
          ],
        ),
      );
    }
  }
}
