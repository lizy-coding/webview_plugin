import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:webview_continer/webview_navigation_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class AndroidWebView extends StatefulWidget {
  final String url;
  final bool showNavigationBar;
  final PreferredSizeWidget? appBar;
  final Color backgroundColor;

  const AndroidWebView({
    super.key,
    required this.url,
    this.showNavigationBar = true,
    this.appBar,
    required this.backgroundColor,
  });

  @override
  _AndroidWebViewState createState() => _AndroidWebViewState();
}

class _AndroidWebViewState extends State<AndroidWebView> with SingleTickerProviderStateMixin {
  late WebViewController _controller;
  late AndroidWebViewController _androidController;
  bool _isLoading = true;
  final Logger _logger = Logger('AndroidWebView');
  double _loadingProgress = 0.0;
  String _currentUrl = '';
  late AnimationController _fadeAnimController;
  late Animation<double> _fadeAnimation;
  Timer? _loadingTimer;
  bool _showPlaceholder = true;

  @override
  void initState() {
    super.initState();
    _logger.info('正在初始化 AndroidWebView');
    _currentUrl = widget.url;
    
    // 初始化动画控制器
    _fadeAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeAnimController);
    
    _controller = WebViewController()
      ..setBackgroundColor(widget.backgroundColor)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            _startLoading(url);
          },
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100;
              // 当加载进度超过30%时，可以考虑显示网页内容
              if (progress > 30 && _showPlaceholder) {
                _showPlaceholder = false;
                _fadeAnimController.forward();
              }
            });
            _logger.info('Loading progress: $progress%');
          },
          onPageFinished: (String url) {
            _finishLoading(url);
          },
          onWebResourceError: (WebResourceError error) {
            _logger.severe('Web resource error: ${error.description}');
            // 错误处理，确保不会一直显示加载状态
            setState(() {
              _isLoading = false;
              _showPlaceholder = false;
            });
            _fadeAnimController.forward();
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    _androidController = AndroidWebViewController(_controller);
    _logger.info('AndroidWebView 初始化完成');
  }
  
  void _startLoading(String url) {
    _logger.info('Page load started: $url');
    setState(() {
      _isLoading = true;
      _loadingProgress = 0.0;
      _currentUrl = url;
      _showPlaceholder = true;
    });
    _fadeAnimController.reset();
    
    // 设置一个定时器，如果加载时间过长，也显示内容
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showPlaceholder) {
        setState(() {
          _showPlaceholder = false;
        });
        _fadeAnimController.forward();
      }
    });
  }
  
  void _finishLoading(String url) {
    _logger.info('Page load finished: $url');
    _loadingTimer?.cancel();
    setState(() {
      _isLoading = false;
      _loadingProgress = 1.0;
      _showPlaceholder = false;
    });
    _fadeAnimController.forward();
  }
  
  @override
  void dispose() {
    _fadeAnimController.dispose();
    _loadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logger.info('正在构建 AndroidWebView 小部件');
    return Scaffold(
      appBar: widget.appBar ?? _buildDefaultAppBar(),
      body: Stack(
        children: [
          // 网页内容与淡入动画
          FadeTransition(
            opacity: _fadeAnimation,
            child: WebViewWidget(controller: _controller),
          ),
          
          // 加载占位内容
          if (_showPlaceholder)
            _buildLoadingPlaceholder(),
          
          // 顶部进度条
          if (_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _loadingProgress,
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

  PreferredSizeWidget _buildDefaultAppBar() {
    _logger.info('正在构建默认 AppBar'); // 构建 AppBar 日志
    if (!widget.showNavigationBar) {
      _logger.info('导航栏隐藏，返回简单 AppBar'); // 返回简单 AppBar 日志
      return AppBar();
    }
    _logger.info('返回 WebViewNavigationBar'); // 返回 WebViewNavigationBar 日志
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: WebViewNavigationBar(
        controller: _androidController,
        logger: _logger,
      ),
    );
  }
}
