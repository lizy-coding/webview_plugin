import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:webview_continer/webview_navigation_bar.dart';
import 'package:webview_windows/webview_windows.dart';
import 'dart:async';

class WindowsWebView extends StatefulWidget {
  final String url;
  final bool showNavigationBar;
  final PreferredSizeWidget? appBar;
  final Color backgroundColor;

  const WindowsWebView({
    super.key,
    required this.url,
    this.showNavigationBar = true,
    this.appBar,
    required this.backgroundColor,
  });

  // 创建 WindowsWebView 的状态
  @override
  _WindowsWebViewState createState() => _WindowsWebViewState();
}

class _WindowsWebViewState extends State<WindowsWebView>
    with SingleTickerProviderStateMixin {
  final WebviewController _controller = WebviewController();
  WindowsWebViewController? _windowsController;
  final Logger _logger = Logger('WindowsWebView');
  bool _isLoading = true;
  String _currentUrl = '';
  late AnimationController _fadeAnimController;
  late Animation<double> _fadeAnimation;
  Timer? _loadingTimer;
  bool _showPlaceholder = true;
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;

    // 初始化动画控制器
    _fadeAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeAnimController);

    _initPlatformState();
  }

  @override
  void dispose() {
    _fadeAnimController.dispose();
    _loadingTimer?.cancel();
    super.dispose();
  }

  // 初始化 WebView 控制器和加载 URL
  Future<void> _initPlatformState() async {
    try {
      // 初始化 WebView 控制器
      await _controller.initialize();
      _logger.info('WebView controller initialized successfully');

      await _controller.setBackgroundColor(widget.backgroundColor);
      _logger.info('Background color set successfully');

      // 设置弹出窗口策略为拒绝
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      _logger.info('Popup window policy set successfully');

      // 监听加载状态变化
      _setupNavigationEvents();

      // 设置定时器，如果加载时间过长，也显示内容
      _loadingTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _showPlaceholder) {
          setState(() {
            _showPlaceholder = false;
          });
          _fadeAnimController.forward();
        }
      });

      // 加载指定的 URL
      await _controller.loadUrl(widget.url);
      _logger.info('URL loaded successfully: ${widget.url}');

      // 创建 Windows WebView 控制器
      _windowsController = WindowsWebViewController(_controller, _logger);
    } catch (e, stackTrace) {
      // 处理初始化错误
      _logger.severe('Error initializing WebView: $e', e, stackTrace);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showPlaceholder = false;
        });
        _fadeAnimController.forward();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load WebView: ${e.toString()}')),
        );
      }
    }
  }

  void _setupNavigationEvents() {
    // Windows WebView 没有直接的导航事件，需要通过 JavaScript 监听
    _controller.addScriptToExecuteOnDocumentCreated("""
      window.addEventListener('load', function() {
        window.chrome.webview.postMessage('PAGE_LOADED');
      });
      
      let loadingStartTime = Date.now();
      let progressInterval = setInterval(function() {
        let elapsed = Date.now() - loadingStartTime;
        let progress = Math.min(elapsed / 5000, 0.9); // 最多到90%
        window.chrome.webview.postMessage('PROGRESS:' + progress);
        if (progress >= 0.9) clearInterval(progressInterval);
      }, 100);
    """);

    _controller.webMessage.listen((message) {
      if (message == 'PAGE_LOADED') {
        _finishLoading();
      } else if (message.startsWith('PROGRESS:')) {
        try {
          double progress = double.parse(message.split(':')[1]);
          setState(() {
            _loadingProgress = progress;
            // 当加载进度超过30%时，可以考虑显示网页内容
            if (progress > 0.3 && _showPlaceholder) {
              _showPlaceholder = false;
              _fadeAnimController.forward();
            }
          });
        } catch (e) {
          _logger.warning('Error parsing progress: $e');
        }
      }
    });
  }

  void _finishLoading() {
    _logger.info('Page load finished');
    _loadingTimer?.cancel();
    setState(() {
      _isLoading = false;
      _loadingProgress = 1.0;
      _showPlaceholder = false;
    });
    _fadeAnimController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar ?? _buildDefaultAppBar(),
      body: Stack(
        children: [
          // 网页内容与淡入动画
          FadeTransition(
            opacity: _fadeAnimation,
            child: Webview(_controller),
          ),

          // 加载占位内容
          if (_showPlaceholder) _buildLoadingPlaceholder(),

          // 顶部进度条
          if (_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _loadingProgress > 0 ? _loadingProgress : null,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                minHeight: 3,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    // 构建加载占位界面，模拟网页内容
    return Container(
      color: widget.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 模拟顶部横幅
          Container(
            height: 180,
            color: Colors.grey.withOpacity(0.1),
            margin: const EdgeInsets.all(8.0),
          ),

          // 模拟内容块
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(5, (index) {
                return Container(
                  height: 20,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

          // 模拟图片内容
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            color: Colors.grey.withOpacity(0.1),
          ),

          const SizedBox(height: 16),

          // 加载中提示
          Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(height: 12),
                Text(
                  '正在加载 $_currentUrl',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建默认的应用栏
  PreferredSizeWidget? _buildDefaultAppBar() {
    if (!widget.showNavigationBar) return null;
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: _windowsController != null
          ? WebViewNavigationBar(
              // 使用自定义的 WebView 导航栏
              controller: _windowsController!,
              logger: _logger,
            )
          : AppBar(), // 如果控制器未初始化，则显示默认 AppBar
    );
  }
}
