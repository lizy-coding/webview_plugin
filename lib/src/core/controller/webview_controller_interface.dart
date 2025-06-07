/// WebView controller interface that defines common WebView operations
/// across different platforms.
///
/// This interface provides a unified API for both Android and Windows platforms,
/// allowing platform-specific implementations to be used interchangeably.
abstract class WebViewControllerInterface {
  /// Checks if the WebView can navigate back
  Future<bool> canGoBack();

  /// Checks if the WebView can navigate forward
  Future<bool> canGoForward();

  /// Navigates back in the WebView history
  Future<void> goBack();

  /// Navigates forward in the WebView history
  Future<void> goForward();

  /// Reloads the current page
  Future<void> reload();

  /// Loads the specified URL
  Future<void> loadUrl(String url);
}
