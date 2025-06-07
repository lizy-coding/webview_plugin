import 'package:flutter/material.dart';

/// Configuration class for WebView settings.
///
/// This class centralizes all configuration options for WebView instances,
/// making it easier to add new options without changing constructors.
class WebViewConfiguration {
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

  /// Creates a WebView configuration with the specified settings.
  const WebViewConfiguration({
    required this.url,
    this.showNavigationBar = true,
    this.appBar,
    this.backgroundColor = Colors.white,
    this.fadeAnimationDuration = 300,
    this.showContentThreshold = 0.3,
    this.loadingTimeoutSeconds = 3,
  });
  
  /// Creates a copy of this configuration with the specified fields replaced.
  WebViewConfiguration copyWith({
    String? url,
    bool? showNavigationBar,
    PreferredSizeWidget? appBar,
    Color? backgroundColor,
    int? fadeAnimationDuration,
    double? showContentThreshold,
    int? loadingTimeoutSeconds,
  }) {
    return WebViewConfiguration(
      url: url ?? this.url,
      showNavigationBar: showNavigationBar ?? this.showNavigationBar,
      appBar: appBar ?? this.appBar,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fadeAnimationDuration: fadeAnimationDuration ?? this.fadeAnimationDuration,
      showContentThreshold: showContentThreshold ?? this.showContentThreshold,
      loadingTimeoutSeconds: loadingTimeoutSeconds ?? this.loadingTimeoutSeconds,
    );
  }
}
