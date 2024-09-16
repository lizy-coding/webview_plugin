import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart';

// WebView控制器接口，定义了通用的WebView操作
abstract class WebViewControllerInterface<T> {
  T get controller;
  Future<bool> canGoBack();
  Future<bool> canGoForward();
  Future<void> goBack();
  Future<void> goForward();
  Future<void> reload();
}

// Android平台的WebView控制器实现
class AndroidWebViewController
    extends WebViewControllerInterface<WebViewController> {
  @override
  final WebViewController controller;

  AndroidWebViewController(this.controller);

  // 实现接口定义的方法
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
class WindowsWebViewController
    extends WebViewControllerInterface<WebviewController> {
  @override
  final WebviewController controller;
  // Windows平台始终可以前进后退
  final bool _canGoBack = true;
  final bool _canGoForward = true;

  WindowsWebViewController(this.controller) {
    _setupNavigationStateListeners();
  }

  // 设置导航状态监听器
  void _setupNavigationStateListeners() {
    controller.historyChanged.listen((HistoryChanged event) {});
  }

  // 实现接口定义的方法
  @override
  Future<bool> canGoBack() async => _canGoBack;

  @override
  Future<bool> canGoForward() async => _canGoForward;

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

// WebView控制器工厂类，用于创建适合当前平台的控制器
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

// WebView导航栏组件
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
