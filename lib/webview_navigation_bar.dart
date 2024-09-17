import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart';
import 'dart:io' show Platform;

// WebView控制器接口，定义了通用的WebView操作
abstract class WebViewControllerInterface {
  Future<bool> canGoBack();
  Future<bool> canGoForward();
  Future<void> goBack();
  Future<void> goForward();
  Future<void> reload();
  Future<void> loadUrl(String url);
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

  @override
  Future<void> loadUrl(String url) => controller.loadRequest(Uri.parse(url));
}

// Windows平台的WebView控制器实现
class WindowsWebViewController implements WebViewControllerInterface {
  final WebviewController controller;
  final Logger logger;

  WindowsWebViewController(this.controller, this.logger);

  @override
  Future<bool> canGoBack() async {
    return true;
  }

  @override
  Future<bool> canGoForward() async {
    return true;
  }

  @override
  Future<void> goBack() async {
    await controller.executeScript('history.back()');
    logger.info('Executed goBack');
  }

  @override
  Future<void> goForward() async {
    await controller.executeScript('history.forward()');
    logger.info('Executed goForward');
  }

  @override
  Future<void> reload() async {
    await controller.reload();
    logger.info('Executed reload');
  }

  @override
  Future<void> loadUrl(String url) async {
    await controller.loadUrl(url);
    logger.info('Loaded URL: $url');
  }
}

// WebView导航栏组件
class WebViewNavigationBar extends StatelessWidget {
  final WebViewControllerInterface controller;
  final Logger logger;

  WebViewNavigationBar({
    Key? key,
    required this.controller,
    required this.logger,
  }) : super(key: key);

  final TextEditingController _urlController = TextEditingController();

  void _submitUrl(BuildContext context) {
    String url = _urlController.text.trim();
    if (url.isEmpty) {
      _showErrorDialog(context, '请输入网址');
      return;
    }

    if (!_isValidUrl(url)) {
      _showErrorDialog(context, '请输入有效的网址');
      return;
    }

    controller.loadUrl(url);
    logger.info('加载新网址: $url');
  }

// 验证URL是否有效
  bool _isValidUrl(String url) {
    logger.info('Validating URL: $url');
    return Uri.tryParse(url)?.hasAbsolutePath ?? false;
  }

  void _showErrorDialog(BuildContext context, String message) {
    if (Platform.isAndroid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else if (Platform.isWindows) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('错误'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text('确定'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
    logger.warning(message);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: _urlController,
        decoration: InputDecoration(
          hintText: '输入网址',
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _submitUrl(context),
          ),
        ),
        onSubmitted: (_) => _submitUrl(context),
      ),
      actions: [
        NavigationButton(
          icon: Icons.arrow_back,
          onPressed: () async {
            if (await controller.canGoBack()) {
              await controller.goBack();
              logger.info('返回上一页');
            } else {
              logger.info('无法返回上一页');
            }
          },
        ),
        NavigationButton(
          icon: Icons.arrow_forward,
          onPressed: () async {
            if (await controller.canGoForward()) {
              await controller.goForward();
              logger.info('前进到下一页');
            } else {
              logger.info('无法前进到下一页');
            }
          },
        ),
        NavigationButton(
          icon: Icons.refresh,
          onPressed: () {
            controller.reload();
            logger.info('页面刷新');
          },
        ),
      ],
    );
  }
}

// 导航按钮组件
class NavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const NavigationButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }
}
