import 'package:webview_flutter/webview_flutter.dart';
import '../../core/controller/webview_controller_interface.dart';

/// Android-specific implementation of the WebView controller interface.
///
/// This class wraps the platform-specific WebViewController from webview_flutter
/// and implements the common WebViewControllerInterface.
class AndroidWebViewController implements WebViewControllerInterface {
  final WebViewController _controller;

  /// Creates an Android WebView controller with the specified WebViewController.
  AndroidWebViewController(this._controller);

  @override
  Future<bool> canGoBack() async {
    return await _controller.canGoBack();
  }

  @override
  Future<bool> canGoForward() async {
    return await _controller.canGoForward();
  }

  @override
  Future<void> goBack() async {
    await _controller.goBack();
  }

  @override
  Future<void> goForward() async {
    await _controller.goForward();
  }

  @override
  Future<void> reload() async {
    await _controller.reload();
  }

  @override
  Future<void> loadUrl(String url) async {
    await _controller.loadRequest(Uri.parse(url));
  }
  
  /// Returns the underlying WebViewController.
  ///
  /// This allows access to platform-specific features when needed.
  WebViewController get controller => _controller;
}
