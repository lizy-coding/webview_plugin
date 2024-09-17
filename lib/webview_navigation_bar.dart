import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart';

// WebView控制器接口，定义了通用的WebView操作
abstract class WebViewControllerInterface {
  Future<bool> canGoBack();
  Future<bool> canGoForward();
  Future<void> goBack();
  Future<void> goForward();
  Future<void> reload();
}

// Android平台的WebView控制器实现
class AndroidWebViewController implements WebViewControllerInterface {
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

// Windows平台的WebView控制器实现
class WindowsWebViewController implements WebViewControllerInterface {
  final WebviewController controller;

  WindowsWebViewController(this.controller);

  @override
  Future<bool> canGoBack() async {
    final result = await controller.executeScript('history.length > 1');
    return result == 'true';
  }

  @override
  Future<bool> canGoForward() async {
    final result = await controller.executeScript('!!window.history.forward');
    return result == 'true';
  }

  @override
  Future<void> goBack() => controller.goBack();

  @override
  Future<void> goForward() => controller.goForward();

  @override
  Future<void> reload() => controller.reload();
}

// WebView导航栏组件
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
        // 后退按钮
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            controller.goBack();
            logger.info('尝试返回上一页');
          },
        ),
        // 前进按钮
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            controller.goForward();
            logger.info('尝试前进到下一页');
          },
        ),
        // 刷新按钮
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            controller.reload();
            logger.info('页面刷新');
          },
        ),
      ],
    );
  }
}
