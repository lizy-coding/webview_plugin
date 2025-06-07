import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:logging/logging.dart';

import '../../core/loading_manager.dart';
import '../../core/webview_configuration.dart';
import '../../ui/navigation_bar.dart';
import '../../ui/loading_placeholder.dart';
import 'android_controller.dart';

/// Android-specific WebView implementation.
///
/// This widget uses webview_flutter to provide WebView functionality on Android
/// with optimized loading experience including skeleton screens and animations.
class AndroidWebView extends StatefulWidget {
  /// The URL to load in the WebView
  final String url;
  
  /// Whether to show the navigation bar
  final bool showNavigationBar;
  
  /// Custom AppBar to use instead of the default one
  final PreferredSizeWidget? appBar;
  
  /// Background color for the WebView
  final Color backgroundColor;

  /// Creates an Android WebView with the specified settings.
  const AndroidWebView({
    Key? key,
    required this.url,
    this.showNavigationBar = true,
    this.appBar,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  State<AndroidWebView> createState() => _AndroidWebViewState();
}

class _AndroidWebViewState extends State<AndroidWebView> with TickerProviderStateMixin {
  final Logger _logger = Logger('AndroidWebView');
  late WebViewController _webViewController;
  late AndroidWebViewController _controller;
  late WebViewConfiguration _config;
  late WebViewLoadingManager _loadingManager;
  String _currentUrl = '';
  
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
  
  void _initWebView() {
    _logger.info('Initializing Android WebView with URL: ${widget.url}');
    
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            _logger.info('Page started loading: $url');
            setState(() {
              _currentUrl = url;
              _loadingManager.startLoading(url);
            });
          },
          onProgress: (int progress) {
            _logger.info('Loading progress: $progress%');
            setState(() {
              _loadingManager.updateLoadingProgress(progress / 100.0, _currentUrl);
            });
          },
          onPageFinished: (String url) {
            _logger.info('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            _logger.severe('Web resource error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    
    _controller = AndroidWebViewController(_webViewController);
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
                  child: WebViewWidget(
                    controller: _webViewController,
                  ),
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
                _webViewController.loadRequest(Uri.parse(url));
                setState(() {
                  _currentUrl = url;
                });
              },
            ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _loadingManager.dispose();
    super.dispose();
  }
}
