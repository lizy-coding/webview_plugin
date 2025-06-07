library webview_plugin;

// Core exports
export 'src/core/controller/webview_controller_interface.dart';
export 'src/core/webview_configuration.dart';

// UI components
export 'src/ui/navigation_bar.dart';
export 'src/ui/loading_placeholder.dart';

// Main container widget
export 'src/ui/webview_container.dart';

// Utils
export 'src/utils/logger_util.dart';

// Import for implementation
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'src/core/webview_configuration.dart';
import 'src/utils/logger_util.dart';
import 'dart:io';

/// Main WebView widget that automatically selects the appropriate
/// platform-specific implementation.
///
/// This is the primary entry point for using the WebView plugin.
class WebView extends StatefulWidget {
  /// The URL to load in the WebView
  final String url;

  /// Whether to show the navigation bar
  final bool showNavigationBar;

  /// Custom AppBar to use instead of the default one
  final PreferredSizeWidget? appBar;

  /// Background color for the WebView
  final Color backgroundColor;

  /// Loading animation duration in milliseconds
  final int fadeAnimationDuration;

  /// Progress threshold (0.0 to 1.0) at which to show the actual content
  final double showContentThreshold;

  /// Timeout in seconds after which to show content even if loading is not complete
  final int loadingTimeoutSeconds;

  /// Creates a WebView with the specified settings.
  ///
  /// The [url] parameter is required and specifies the initial URL to load.
  const WebView({
    super.key,
    required this.url,
    this.showNavigationBar = true,
    this.appBar,
    this.backgroundColor = Colors.white,
    this.fadeAnimationDuration = 300,
    this.showContentThreshold = 0.3,
    this.loadingTimeoutSeconds = 3,
  });

  @override
  State<WebView> createState() => _WebViewState();

  /// Initialize the logging system for the WebView plugin.
  ///
  /// Call this method in your app's initialization to set up logging.
  static void initializeLogging({Level logLevel = Level.INFO}) {
    LoggerUtil.setupLogging(logLevel: logLevel);
  }
}

class _WebViewState extends State<WebView> {
  @override
  Widget build(BuildContext context) {
    // Create configuration from widget parameters
    final config = WebViewConfiguration(
      url: widget.url,
      showNavigationBar: widget.showNavigationBar,
      appBar: widget.appBar,
      backgroundColor: widget.backgroundColor,
      fadeAnimationDuration: widget.fadeAnimationDuration,
      showContentThreshold: widget.showContentThreshold,
      loadingTimeoutSeconds: widget.loadingTimeoutSeconds,
    );

    // Import platform-specific implementation
    if (Platform.isAndroid) {
      // Lazy import to avoid loading unnecessary platform code
      return _getAndroidWebView(config);
    } else if (Platform.isWindows) {
      // Lazy import to avoid loading unnecessary platform code
      return _getWindowsWebView(config);
    } else {
      // Fallback for unsupported platforms
      return _getUnsupportedPlatformWidget();
    }
  }

  Widget _getAndroidWebView(WebViewConfiguration config) {
    // Dynamically import Android implementation
    // This will be replaced with proper implementation in the future
    return Center(
        child: Text('Android WebView will be loaded for: ${config.url}'));
  }

  Widget _getWindowsWebView(WebViewConfiguration config) {
    // Dynamically import Windows implementation
    // This will be replaced with proper implementation in the future
    return Center(
        child: Text('Windows WebView will be loaded for: ${config.url}'));
  }

  Widget _getUnsupportedPlatformWidget() {
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
