import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:webview_continer/webview_navigation_bar.dart';
import 'package:webview_windows/webview_windows.dart';

class WindowsWebView extends StatefulWidget {
  final String url;
  final bool showNavigationBar;
  final PreferredSizeWidget? appBar;
  final Color backgroundColor;

  const WindowsWebView({
    super.key,
    required this.url,
    this.showNavigationBar = true,
    this.appBar,
    required this.backgroundColor,
  });

  // 创建 WindowsWebView 的状态
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

  // 初始化 WebView 控制器和加载 URL
  Future<void> _initPlatformState() async {
    try {
      // 初始化 WebView 控制器
      await _controller.initialize();
      _logger.info('WebView controller initialized successfully');

      await _controller.setBackgroundColor(widget.backgroundColor);
      _logger.info('Background color set successfully');

      // 设置弹出窗口策略为拒绝
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      _logger.info('Popup window policy set successfully');

      // 加载指定的 URL
      await _controller.loadUrl(widget.url);
      _logger.info('URL loaded successfully: ${widget.url}');

      // 创建 Windows WebView 控制器
      _windowsController = WindowsWebViewController(_controller, _logger);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      // 处理初始化错误
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
          if (_isLoading)
            const Center(child: CircularProgressIndicator()), // 加载时显示进度指示器
        ],
      ),
    );
  }

  // 构建默认的应用栏
  PreferredSizeWidget? _buildDefaultAppBar() {
    if (!widget.showNavigationBar) return null;
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: _windowsController != null
          ? WebViewNavigationBar(
              // 使用自定义的 WebView 导航栏
              controller: _windowsController!,
              logger: _logger,
            )
          : AppBar(), // 如果控制器未初始化，则显示默认 AppBar
    );
  }
}
