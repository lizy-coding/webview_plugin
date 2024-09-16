import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart';

abstract class WebViewControllerInterface {
  Future<bool> canGoBack();
  Future<bool> canGoForward();
  void goBack();
  void goForward();
  void reload();
}

class AndroidWebViewController implements WebViewControllerInterface {
  final WebViewController controller;

  AndroidWebViewController(this.controller);

  @override
  Future<bool> canGoBack() => controller.canGoBack();

  @override
  Future<bool> canGoForward() => controller.canGoForward();

  @override
  void goBack() => controller.goBack();

  @override
  void goForward() => controller.goForward();

  @override
  void reload() => controller.reload();
}

class WindowsWebViewController implements WebViewControllerInterface {
  final WebviewController controller;

  WindowsWebViewController(this.controller);

  @override
  Future<bool> canGoBack() async => false;

  @override
  Future<bool> canGoForward() async => false;

  @override
  void goBack() {}

  @override
  void goForward() {}

  @override
  void reload() {}
}

class WebViewNavigationBar extends StatelessWidget {
  final WebViewControllerInterface controller;
  final Logger logger;

  const WebViewNavigationBar({
    super.key,
    required this.controller,
    required this.logger,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('WebView'),
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (await controller.canGoBack()) {
              controller.goBack();
              logger.info('Navigated back');
            } else {
              logger.info('Cannot go back');
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () async {
            if (await controller.canGoForward()) {
              controller.goForward();
              logger.info('Navigated forward');
            } else {
              logger.info('Cannot go forward');
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            controller.reload();
            logger.info('Page reloaded');
          },
        ),
      ],
    );
  }
}
