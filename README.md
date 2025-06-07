# WebView Plugin

跨平台 WebView 插件，支持 Android 和 Windows 平台，提供统一的 API 和优化的用户体验。

## 功能特点

- 跨平台支持（Android 和 Windows）
- 统一的 API 接口
- 内置导航栏，支持前进、后退、刷新等操作
- 优化的加载体验，包括骨架屏和平滑过渡动画
- 加载进度指示器
- 可自定义外观

## 文件结构

### 当前结构

```
lib/
├── android_platform/
│   └── android_webview.dart      # Android 平台实现
├── windows_platform/
│   └── windows_webview.dart      # Windows 平台实现
├── webview_container.dart        # 主要容器组件
└── webview_navigation_bar.dart   # 导航栏组件
```

### 优化后的结构

```
lib/
├── src/
│   ├── core/
│   │   ├── webview_controller_interface.dart  # 控制器接口
│   │   └── webview_configuration.dart         # 配置类
│   ├── platforms/
│   │   ├── android/
│   │   │   ├── android_webview.dart           # Android 实现
│   │   │   └── android_controller.dart        # Android 控制器
│   │   └── windows/
│   │       ├── windows_webview.dart           # Windows 实现
│   │       └── windows_controller.dart        # Windows 控制器
│   ├── ui/
│   │   ├── navigation_bar.dart                # 导航栏组件
│   │   └── loading_placeholder.dart           # 共享加载 UI
│   └── utils/
│       └── logger_util.dart                   # 集中式日志
└── webview.dart                               # 主入口点（导出）
```

### 结构优化的主要改进

1. **关注点分离**
   - 控制器接口与实现分离
   - UI 组件与平台特定代码隔离
   - 提取共享加载 UI 组件

2. **提高可维护性**
   - 更小、更专注的文件，职责清晰
   - 一致的命名约定
   - 相关组件的更好组织

3. **增强可扩展性**
   - 更容易添加新平台支持
   - 灵活配置的配置类
   - 明确的扩展点

## 主要 API

### WebViewContainer

主要的容器组件，根据平台自动选择合适的实现。

```dart
WebViewContainer({
  required String url,            // 要加载的 URL
  bool showNavigationBar = true,  // 是否显示导航栏
  PreferredSizeWidget? appBar,    // 自定义 AppBar
  Color backgroundColor = Colors.white, // 背景颜色
});
```

### WebViewControllerInterface

统一的 WebView 控制器接口，定义了通用的 WebView 操作。

```dart
abstract class WebViewControllerInterface {
  Future<bool> canGoBack();       // 是否可以返回上一页
  Future<bool> canGoForward();    // 是否可以前进到下一页
  Future<void> goBack();          // 返回上一页
  Future<void> goForward();       // 前进到下一页
  Future<void> reload();          // 重新加载当前页面
  Future<void> loadUrl(String url); // 加载指定 URL
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
