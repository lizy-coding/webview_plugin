import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart';

abstract class WebViewControllerInterface<T> {
  T get controller;
  Future<bool> canGoBack();
  Future<bool> canGoForward();
  Future<void> goBack();
  Future<void> goForward();
  Future<void> reload();
}

class AndroidWebViewController
    extends WebViewControllerInterface<WebViewController> {
  @override
  final WebViewController controller;

  AndroidWebViewController(this.controller);

  @override
  Future<bool> canGoBack() => controller.canGoBack();

  @override
  Future<bool> canGoForward() => controller.canGoForward();

  @override
  Future<void> goBack() => controller.goBack();

  @override
  Future<void> goForward() => controller.goForward();

  @override
  Future<void> reload() => controller.reload();
}

class WindowsWebViewController
    extends WebViewControllerInterface<WebviewController> {
  @override
  final WebviewController controller;
  // windows 平台始终可以前进后退
  final bool _canGoBack = true;
  final bool _canGoForward = true;

  WindowsWebViewController(this.controller) {
    _setupNavigationStateListeners();
  }

  void _setupNavigationStateListeners() {
    controller.historyChanged.listen((HistoryChanged event) {});
  }

  @override
  Future<bool> canGoBack() async {
    return _canGoBack;
  }

  @override
  Future<bool> canGoForward() async {
    return _canGoForward;
  }

  @override
  Future<void> goBack() async {
    if (_canGoBack) {
      await controller.goBack();
    }
  }

  @override
  Future<void> goForward() async {
    if (_canGoForward) {
      await controller.goForward();
    }
  }

  @override
  Future<void> reload() => controller.reload();
}

class WebViewControllerFactory {
  static WebViewControllerInterface create(dynamic controller) {
    if (controller is WebViewController) {
      return AndroidWebViewController(controller);
    } else if (controller is WebviewController) {
      return WindowsWebViewController(controller);
    }
    throw UnsupportedError(
        'Unsupported controller type: ${controller.runtimeType}');
  }
}

class WebViewNavigationBar<T> extends StatelessWidget {
  final WebViewControllerInterface<T> controller;
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
          onPressed: () {
            controller.goBack();
            logger.info('Attempted to navigate back');
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            controller.goForward();
            logger.info('Attempted to navigate forward');
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
