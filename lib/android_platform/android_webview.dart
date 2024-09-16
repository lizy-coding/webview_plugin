import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:webview_continer/webview_navigation_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AndroidWebView extends StatefulWidget {
  final String url;
  final bool showNavigationBar;
  final PreferredSizeWidget? appBar;

  const AndroidWebView({
    super.key,
    required this.url,
    this.showNavigationBar = true,
    this.appBar,
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
    _controller = WebViewController()
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
  }

  @override
  Widget build(BuildContext context) {
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
    if (!widget.showNavigationBar) return AppBar();
    return WebViewNavigationBar(
      controller: _androidController,
      logger: _logger,
    ) as PreferredSizeWidget;
  }
}
