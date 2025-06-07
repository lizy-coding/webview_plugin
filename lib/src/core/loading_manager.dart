import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'webview_configuration.dart';

/// Manages the loading state and animations for WebView implementations.
///
/// This class centralizes the loading logic that was previously duplicated
/// in both Android and Windows WebView implementations.
class WebViewLoadingManager {
  final Logger _logger = Logger('WebViewLoadingManager');
  final WebViewConfiguration _config;
  
  /// Animation controller for the fade transition
  final AnimationController fadeController;
  
  /// Current loading progress (0.0 to 1.0)
  double _loadingProgress = 0.0;
  
  /// Whether the content is ready to be displayed
  bool _isContentReady = false;
  
  /// Timer for loading timeout
  Timer? _loadingTimer;
  
  /// Current URL being loaded
  String _currentUrl = '';

  /// Creates a WebView loading manager with the specified configuration.
  WebViewLoadingManager({
    required WebViewConfiguration config,
    required TickerProvider vsync,
  }) : _config = config,
       fadeController = AnimationController(
         vsync: vsync,
         duration: Duration(milliseconds: config.fadeAnimationDuration),
       );

  /// The current loading progress (0.0 to 1.0)
  double get loadingProgress => _loadingProgress;
  
  /// Whether the content is ready to be displayed
  bool get isContentReady => _isContentReady;
  
  /// The current URL being loaded
  String get currentUrl => _currentUrl;

  /// Updates the loading progress and determines if content should be shown.
  ///
  /// This method implements the smart loading logic that shows content
  /// once a threshold is reached or after a timeout.
  void updateLoadingProgress(double progress, String url) {
    _loadingProgress = progress;
    _currentUrl = url;
    
    _logger.info('Loading progress: $progress for URL: $url');
    
    // Show content if progress exceeds threshold
    if (progress >= _config.showContentThreshold && !_isContentReady) {
      _showContent();
    }
  }

  /// Starts loading a new URL.
  ///
  /// This resets the loading state and starts the timeout timer.
  void startLoading(String url) {
    _loadingProgress = 0.0;
    _isContentReady = false;
    _currentUrl = url;
    fadeController.reverse();
    
    _logger.info('Started loading URL: $url');
    
    // Cancel any existing timer
    _loadingTimer?.cancel();
    
    // Start timeout timer
    _loadingTimer = Timer(Duration(seconds: _config.loadingTimeoutSeconds), () {
      if (!_isContentReady) {
        _showContent();
        _logger.info('Loading timeout reached, showing content');
      }
    });
  }

  /// Shows the content by updating state and animating the fade transition.
  void _showContent() {
    _isContentReady = true;
    fadeController.forward();
    _logger.info('Showing content for URL: $_currentUrl');
  }

  /// Disposes resources used by the loading manager.
  void dispose() {
    fadeController.dispose();
    _loadingTimer?.cancel();
  }
}
