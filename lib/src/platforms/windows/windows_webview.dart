import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:logging/logging.dart';

import '../../core/loading_manager.dart';
import '../../core/webview_configuration.dart';
import '../../ui/navigation_bar.dart';
import '../../ui/loading_placeholder.dart';
import 'windows_controller.dart';

/// Windows-specific WebView implementation.
///
/// This widget uses webview_windows to provide WebView functionality on Windows
/// with optimized loading experience including skeleton screens and animations.
class WindowsWebView extends StatefulWidget {
  /// The URL to load in the WebView
  final String url;
  
  /// Whether to show the navigation bar
  final bool showNavigationBar;
  
  /// Custom AppBar to use instead of the default one
  final PreferredSizeWidget? appBar;
  
  /// Background color for the WebView
  final Color backgroundColor;

  /// Creates a Windows WebView with the specified settings.
  const WindowsWebView({
    Key? key,
    required this.url,
    this.showNavigationBar = true,
    this.appBar,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  State<WindowsWebView> createState() => _WindowsWebViewState();
}

class _WindowsWebViewState extends State<WindowsWebView> with TickerProviderStateMixin {
  final Logger _logger = Logger('WindowsWebView');
  final WebviewController _webviewController = WebviewController();
  late WindowsWebViewController _controller;
  late WebViewConfiguration _config;
  late WebViewLoadingManager _loadingManager;
  String _currentUrl = '';
  Timer? _progressTimer;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize configuration
    _config = WebViewConfiguration(
      url: widget.url,
      showNavigationBar: widget.showNavigationBar,
      appBar: widget.appBar,
      backgroundColor: widget.backgroundColor,
    );
    
    // Initialize loading manager
    _loadingManager = WebViewLoadingManager(
      config: _config,
      vsync: this,
    );
    
    _currentUrl = widget.url;
    _initWebView();
  }
  
  Future<void> _initWebView() async {
    _logger.info('Initializing Windows WebView with URL: ${widget.url}');
    
    try {
      await _webviewController.initialize();
      _controller = WindowsWebViewController(_webviewController);
      
      _webviewController.loadUrl(widget.url);
      
      // Add JavaScript to track loading progress
      await _webviewController.executeScript('''
        window.addEventListener('load', function() {
          window.chrome.webview.postMessage('LOAD_COMPLETE');
        });
      ''');
      
      // Listen for messages from JavaScript
      _webviewController.webMessage.listen((message) {
        if (message == 'LOAD_COMPLETE') {
          _logger.info('Page load complete via JavaScript message');
          _loadingManager.updateLoadingProgress(1.0, _currentUrl);
        }
      });
      
      // Start loading process
      _loadingManager.startLoading(widget.url);
      
      // Since webview_windows doesn't provide progress events,
      // we'll simulate progress updates
      _startProgressSimulation();
      
      if (mounted) setState(() {});
    } catch (e) {
      _logger.severe('Failed to initialize WebView: $e');
    }
  }
  
  void _startProgressSimulation() {
    // Cancel any existing timer
    _progressTimer?.cancel();
    
    // Start with 0.1 progress to show something is happening
    double progress = 0.1;
    
    // Update progress every 200ms
    _progressTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (progress >= 0.95) {
        timer.cancel();
        return;
      }
      
      // Simulate realistic loading curve
      if (progress < 0.2) {
        progress += 0.05;
      } else if (progress < 0.5) {
        progress += 0.03;
      } else if (progress < 0.8) {
        progress += 0.02;
      } else {
        progress += 0.01;
      }
      
      if (mounted) {
        setState(() {
          _loadingManager.updateLoadingProgress(progress, _currentUrl);
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: Column(
        children: [
          // Linear progress indicator at the top
          if (!_loadingManager.isContentReady)
            LinearProgressIndicator(
              value: _loadingManager.loadingProgress > 0.0 ? _loadingManager.loadingProgress : null,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 3,
            ),
            
          // Main content area
          Expanded(
            child: Stack(
              children: [
                // Loading placeholder
                if (!_loadingManager.isContentReady)
                  LoadingPlaceholder(
                    currentUrl: _currentUrl,
                    backgroundColor: widget.backgroundColor,
                  ),
                
                // Actual WebView with fade transition
                FadeTransition(
                  opacity: _loadingManager.fadeController,
                  child: Webview(_webviewController),
                ),
              ],
            ),
          ),
          
          // Navigation bar
          if (widget.showNavigationBar)
            WebViewNavigationBar(
              controller: _controller,
              currentUrl: _currentUrl,
              onUrlChanged: (String url) {
                _webviewController.loadUrl(url);
                setState(() {
                  _currentUrl = url;
                  _loadingManager.startLoading(url);
                  _startProgressSimulation();
                });
              },
            ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _progressTimer?.cancel();
    _loadingManager.dispose();
    _webviewController.dispose();
    super.dispose();
  }
}
