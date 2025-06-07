import 'package:flutter/material.dart';
import '../core/controller/webview_controller_interface.dart';

/// A navigation bar for WebView with URL input and navigation controls.
///
/// This component provides a consistent navigation experience across platforms
/// with forward, back, and refresh buttons, as well as a URL input field.
class WebViewNavigationBar extends StatefulWidget {
  /// The WebView controller to use for navigation
  final WebViewControllerInterface controller;

  /// The current URL displayed in the WebView
  final String currentUrl;

  /// Called when a new URL is entered
  final Function(String) onUrlChanged;

  /// Creates a navigation bar for WebView.
  const WebViewNavigationBar({
    Key? key,
    required this.controller,
    required this.currentUrl,
    required this.onUrlChanged,
  }) : super(key: key);

  @override
  State<WebViewNavigationBar> createState() => _WebViewNavigationBarState();
}

class _WebViewNavigationBarState extends State<WebViewNavigationBar> {
  late TextEditingController _urlController;
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.currentUrl);
    _updateNavigationState();
  }

  @override
  void didUpdateWidget(WebViewNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentUrl != widget.currentUrl) {
      _urlController.text = widget.currentUrl;
      _updateNavigationState();
    }
  }

  /// Updates the navigation state (back/forward buttons)
  Future<void> _updateNavigationState() async {
    final canGoBack = await widget.controller.canGoBack();
    final canGoForward = await widget.controller.canGoForward();

    if (mounted) {
      setState(() {
        _canGoBack = canGoBack;
        _canGoForward = canGoForward;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _canGoBack
                ? () {
                    widget.controller.goBack();
                    _updateNavigationState();
                  }
                : null,
          ),
          // Forward button
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _canGoForward
                ? () {
                    widget.controller.goForward();
                    _updateNavigationState();
                  }
                : null,
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              widget.controller.reload();
            },
          ),
          // URL input field
          Expanded(
            child: TextField(
              controller: _urlController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
              ),
              onSubmitted: (url) {
                if (url.isNotEmpty) {
                  final formattedUrl = _formatUrl(url);
                  widget.onUrlChanged(formattedUrl);
                  _urlController.text = formattedUrl;
                }
              },
            ),
          ),
          // Go button
          IconButton(
            icon: const Icon(Icons.arrow_circle_right_outlined),
            onPressed: () {
              final url = _urlController.text;
              if (url.isNotEmpty) {
                final formattedUrl = _formatUrl(url);
                widget.onUrlChanged(formattedUrl);
              }
            },
          ),
        ],
      ),
    );
  }

  /// Formats the URL to ensure it has a proper scheme
  String _formatUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return 'https://$url';
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
