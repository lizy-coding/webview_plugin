import 'package:webview_windows/webview_windows.dart';
import '../../core/controller/webview_controller_interface.dart';

/// Windows-specific implementation of the WebView controller interface.
///
/// This class wraps the platform-specific WebviewController from webview_windows
/// and implements the common WebViewControllerInterface.
class WindowsWebViewController implements WebViewControllerInterface {
  final WebviewController _controller;

  /// Creates a Windows WebView controller with the specified WebviewController.
  WindowsWebViewController(this._controller);

  @override
  Future<bool> canGoBack() async {
    // webview_windows doesn't have direct canGoBack method
    // Use executeScript to check if we can go back
    final result = await _controller.executeScript('history.length > 1');
    return result == true;
  }

  @override
  Future<bool> canGoForward() async {
    // webview_windows doesn't have direct canGoForward method
    // Use executeScript to check if we can go forward
    final result = await _controller.executeScript(
        'window.history.length > 0 && window.history.state != null');
    return result == true;
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
    await _controller.loadUrl(url);
  }
  
  /// Returns the underlying WebviewController.
  ///
  /// This allows access to platform-specific features when needed.
  WebviewController get controller => _controller;
  
  /// Executes JavaScript in the WebView.
  ///
  /// This is a Windows-specific method used for progress tracking.
  Future<dynamic> executeScript(String javaScript) async {
    return await _controller.executeScript(javaScript);
  }
}
