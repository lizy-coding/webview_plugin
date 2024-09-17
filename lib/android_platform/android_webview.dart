import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:webview_continer/webview_navigation_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AndroidWebView extends StatefulWidget {
  final String url;
  final bool showNavigationBar;
  final PreferredSizeWidget? appBar;
  final Color backgroundColor;

  const AndroidWebView({
    super.key,
    required this.url,
    this.showNavigationBar = true,
    this.appBar,
    required this.backgroundColor,
  });

  @override
  _AndroidWebViewState createState() => _AndroidWebViewState();
}

class _AndroidWebViewState extends State<AndroidWebView> {
  late WebViewController _controller;
  late AndroidWebViewController _androidController;
  bool _isLoading = true;
  final Logger _logger = Logger('AndroidWebView');

  @override
  void initState() {
    super.initState();
    _logger.info('正在初始化 AndroidWebView'); // 初始化开始日志
    _controller = WebViewController()
      ..setBackgroundColor(widget.backgroundColor)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            _logger.info('Page load started: $url');
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _logger.info('Page load finished: $url');
          },
          onWebResourceError: (WebResourceError error) {
            _logger.severe('Web resource error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    _androidController = AndroidWebViewController(_controller);
    _logger.info('AndroidWebView 初始化完成'); // 初始化完成日志
  }

  @override
  Widget build(BuildContext context) {
    _logger.info('正在构建 AndroidWebView 小部件'); // 构建小部件日志
    return Scaffold(
      appBar: widget.appBar ?? _buildDefaultAppBar(),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildDefaultAppBar() {
    _logger.info('正在构建默认 AppBar'); // 构建 AppBar 日志
    if (!widget.showNavigationBar) {
      _logger.info('导航栏隐藏，返回简单 AppBar'); // 返回简单 AppBar 日志
      return AppBar();
    }
    _logger.info('返回 WebViewNavigationBar'); // 返回 WebViewNavigationBar 日志
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: WebViewNavigationBar(
        controller: _androidController,
        logger: _logger,
      ),
    );
  }
}
