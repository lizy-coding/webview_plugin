import 'package:flutter/material.dart';

/// A shared loading placeholder widget that displays a skeleton screen
/// while web content is loading.
///
/// This component provides a consistent loading experience across different platforms
/// and helps avoid white screens during page transitions.
class LoadingPlaceholder extends StatelessWidget {
  /// The URL being loaded
  final String currentUrl;
  
  /// The background color for the placeholder
  final Color backgroundColor;

  /// Creates a loading placeholder with skeleton UI
  const LoadingPlaceholder({
    Key? key,
    required this.currentUrl,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header banner placeholder
          Container(
            height: 180,
            color: Colors.grey.withOpacity(0.1),
            margin: const EdgeInsets.all(8.0),
          ),
          
          // Content blocks placeholders
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
          
          // Image content placeholder
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            color: Colors.grey.withOpacity(0.1),
          ),
          
          const SizedBox(height: 16),
          
          // Loading indicator with URL
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
                  '正在加载 $currentUrl',
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
}
