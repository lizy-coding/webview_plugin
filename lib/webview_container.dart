// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:webview_continer/android_platform/android_webview.dart';
import 'package:webview_continer/windows_platform/windows_webview.dart';
import 'dart:io' show Platform;
import 'package:logging/logging.dart';

class WebViewContainer extends StatefulWidget {
  final String url;
  final bool showNavigationBar;
  final PreferredSizeWidget? appBar;
  final Color backgroundColor;

  const WebViewContainer({
    super.key,
    required this.url,
    this.showNavigationBar = true,
    this.appBar,
    this.backgroundColor = Colors.white, // Default to white
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
        backgroundColor: widget.backgroundColor, // Pass background color
      );
    } else if (Platform.isWindows) {
      return WindowsWebView(
        url: widget.url,
        showNavigationBar: widget.showNavigationBar,
        appBar: widget.appBar,
        backgroundColor: widget.backgroundColor, // Pass background color
      );
    } else {
      _logger.warning('Unsupported platform');
      return Container(
        color: widget.backgroundColor, // Apply background color
        child: const Center(child: Text('Unsupported platform')),
      );
    }
  }
}
