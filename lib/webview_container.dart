import 'package:flutter/material.dart';
import 'package:webview_continer/android_platform/android_webview.dart';
import 'package:webview_continer/windows_platform/windows_webview.dart';
import 'dart:io' show Platform;
import 'package:logging/logging.dart';

class WebViewContainer extends StatefulWidget {
  final String url;
  final bool showNavigationBar;
  final PreferredSizeWidget? appBar;

  const WebViewContainer({
    super.key,
    required this.url,
    this.showNavigationBar = true,
    this.appBar,
  });

  @override
  _WebViewContainerState createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  final Logger _logger = Logger('WebViewContainer');

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidWebView(
        url: widget.url,
        showNavigationBar: widget.showNavigationBar,
        appBar: widget.appBar,
      );
    } else if (Platform.isWindows) {
      return WindowsWebView(
        url: widget.url,
        showNavigationBar: widget.showNavigationBar,
        appBar: widget.appBar,
      );
    } else {
      _logger.warning('Unsupported platform');
      return const Center(child: Text('Unsupported platform'));
    }
  }
}
