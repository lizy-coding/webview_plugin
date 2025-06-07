# WebView Plugin

跨平台 WebView 插件，支持 Android 和 Windows 平台，提供统一的 API 和优化的用户体验。

## 功能特点

- 跨平台支持（Android 和 Windows）
- 统一的 API 接口
- 内置导航栏，支持前进、后退、刷新等操作
- 优化的加载体验，包括骨架屏和平滑过渡动画
- 加载进度指示器（顶部进度条和圆形进度指示器）
- 智能加载逻辑（30% 加载或 3 秒超时后显示内容）
- 可自定义外观和配置

## 文件结构

### 当前结构

```
lib/
├── android_platform/
│   └── android_webview.dart      # Android 平台实现
├── windows_platform/
│   └── windows_webview.dart      # Windows 平台实现
├── webview_container.dart        # 主要容器组件
├── webview_navigation_bar.dart   # 导航栏组件
├── src/
│   ├── core/
│   │   ├── controller/
│   │   │   └── webview_controller_interface.dart  # 统一控制器接口
│   │   ├── webview_configuration.dart            # 中央配置类
│   │   └── loading_manager.dart                  # 加载状态管理
│   ├── platforms/
│   │   ├── android/
│   │   │   ├── android_webview.dart              # Android WebView 实现
│   │   │   └── android_controller.dart           # Android 控制器实现
│   │   └── windows/
│   │       ├── windows_webview.dart              # Windows WebView 实现
│   │       └── windows_controller.dart           # Windows 控制器实现
│   ├── ui/
│   │   ├── navigation_bar.dart                   # 共享导航栏组件
│   │   ├── webview_container.dart                # 新的容器组件
│   │   └── loading_placeholder.dart              # 共享加载占位组件
│   └── utils/
│       └── logger_util.dart                      # 统一日志工具
└── webview.dart                                  # 主入口点（API 导出）
```

### 迁移计划

当前我们维护两套并行的结构，以确保兼容性。新的优化结构在 `src/` 目录下，而旧的结构保留在根目录下。在未来的版本中，我们将完全迁移到新结构。

## 架构设计

### 核心组件

1. **WebViewControllerInterface**
   - 定义跨平台统一的 WebView 控制接口
   - 包含导航、刷新和 URL 加载等通用操作

2. **WebViewConfiguration**
   - 集中管理所有 WebView 配置选项
   - 支持自定义加载动画、阈值和超时设置

3. **WebViewLoadingManager**
   - 管理加载状态和过渡动画
   - 实现智能加载逻辑（进度阈值和超时机制）
   - 解决加载时的白屏问题

### 加载优化

1. **骨架屏加载占位**
   - 模拟网页内容的占位组件
   - 避免加载过程中的空白屏幕

2. **平滑过渡动画**
   - 使用 FadeTransition 实现占位符和实际内容之间的平滑过渡
   - 提供更自然的视觉体验

3. **进度指示器**
   - 顶部线性进度条显示加载进度
   - 占位符中的圆形进度指示器

4. **智能加载逻辑**
   - 当加载进度达到 30% 时显示实际内容
   - 3 秒超时机制确保即使进度事件延迟也能显示内容

### 平台实现

1. **Android 平台**
   - 基于 webview_flutter 实现
   - 使用原生进度事件跟踪加载状态
   - AndroidWebViewController 封装平台特定控制器

2. **Windows 平台**
   - 基于 webview_windows 实现
   - 使用 JavaScript 注入和模拟进度更新实现进度跟踪
   - 监听页面加载完成事件

### UI 组件

1. **LoadingPlaceholder**
   - 提供一致的骨架屏加载体验
   - 包含进度指示器和 URL 加载提示

2. **NavigationBar**
   - 统一的导航控制界面
   - 支持 URL 输入和导航操作

## 主要 API

### WebView

新的主要入口类，提供统一的跨平台 WebView 体验。

```dart
// 导入包
import 'package:webview_plugin/webview.dart';

// 在应用初始化时设置日志
@override
void initState() {
  super.initState();
  WebView.initializeLogging();
}

// 使用 WebView 组件
WebView(
  url: 'https://flutter.dev',
  showNavigationBar: true,
  backgroundColor: Colors.white,
  // 加载优化设置
  fadeAnimationDuration: 300,      // 淡入动画时长（毫秒）
  showContentThreshold: 0.3,       // 显示内容的进度阈值（0.0-1.0）
  loadingTimeoutSeconds: 3,        // 加载超时时间（秒）
)
```

### WebViewContainer

兼容旧版本的容器组件，内部使用新的架构。

```dart
// 导入包
import 'package:webview_plugin/webview_container.dart';

// 使用 WebViewContainer 组件
WebViewContainer(
  url: 'https://flutter.dev',
  showNavigationBar: true,
  backgroundColor: Colors.white,
)
```

### WebViewControllerInterface

统一的 WebView 控制器接口，定义了通用的 WebView 操作。

```dart
// 控制器接口定义
abstract class WebViewControllerInterface {
  Future<bool> canGoBack();       // 是否可以返回上一页
  Future<bool> canGoForward();    // 是否可以前进到下一页
  Future<void> goBack();          // 返回上一页
  Future<void> goForward();       // 前进到下一页
  Future<void> reload();          // 重新加载当前页面
  Future<void> loadUrl(String url); // 加载指定 URL
}

// 使用示例
void navigateWebView(WebViewControllerInterface controller) async {
  // 检查是否可以后退
  final canGoBack = await controller.canGoBack();
  
  if (canGoBack) {
    // 后退
    await controller.goBack();
  } else {
    // 加载新 URL
    await controller.loadUrl('https://pub.dev');
  }
  
  // 刷新当前页面
  await controller.reload();
}
```

### 平台特定实现

- **AndroidWebView**: 基于 webview_flutter 实现的 Android WebView
- **WindowsWebView**: 基于 webview_windows 实现的 Windows WebView

## 使用示例

```dart
import 'package:flutter/material.dart';
import 'package:webview_continer/webview_container.dart';

class WebViewExample extends StatelessWidget {
  const WebViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const WebViewContainer(
      url: 'https://flutter.dev',
      backgroundColor: Colors.black,
    );
  }
}
```

## 加载优化

本插件针对页面加载过程进行了优化，提供了更好的用户体验：

1. **骨架屏加载界面**：加载过程中显示网页内容的占位符
2. **平滑过渡动画**：加载完成后平滑过渡到实际内容
3. **进度指示器**：顶部进度条显示实际加载进度
4. **智能加载逻辑**：加载进度达到30%时显示内容，或设置超时自动显示

## 依赖

- Flutter SDK
- webview_flutter: Android 平台支持
- webview_windows: Windows 平台支持
- logging: 日志记录
