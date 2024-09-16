import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:webview_continer/webview_navigation_bar.dart';
import 'package:webview_windows/webview_windows.dart';

class WindowsWebView extends StatefulWidget {
  final String url;
  final bool showNavigationBar;
  final PreferredSizeWidget? appBar;

  const WindowsWebView({
    super.key,
    required this.url,
    this.showNavigationBar = true,
    this.appBar,
  });

  @override
  _WindowsWebViewState createState() => _WindowsWebViewState();
}

class _WindowsWebViewState extends State<WindowsWebView> {
  final WebviewController _controller = WebviewController();
  WindowsWebViewController? _windowsController;
  final Logger _logger = Logger('WindowsWebView');
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    try {
      await _controller.initialize();
      _logger.info('WebView controller initialized successfully');

      await _controller.setBackgroundColor(Colors.transparent);
      _logger.info('Background color set successfully');

      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      _logger.info('Popup window policy set successfully');

      await _controller.loadUrl(widget.url);
      _logger.info('URL loaded successfully: ${widget.url}');

      _windowsController = WindowsWebViewController(_controller);
      _logger.info('WindowsWebViewController created successfully');

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      _logger.severe('Error initializing WebView: $e', e, stackTrace);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load WebView: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar ?? _buildDefaultAppBar(),
      body: Stack(
        children: [
          Webview(_controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  PreferredSizeWidget? _buildDefaultAppBar() {
    if (!widget.showNavigationBar) return null;
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: _windowsController != null
          ? WebViewNavigationBar(
              controller: _windowsController!,
              logger: _logger,
            )
          : AppBar(),
    );
  }
}
