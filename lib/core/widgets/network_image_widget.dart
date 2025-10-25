// lib/core/widgets/network_image_widget.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:navyblue_app/core/services/image_cache_service.dart';

class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Border? border;
  final Color? backgroundColor;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Map<String, String>? httpHeaders;
  final Duration fadeInDuration;
  final Duration placeholderFadeInDuration;
  final VoidCallback? onTap;
  final String? semanticsLabel;
  final bool enableMemoryCache;
  final bool enableDiskCache;
  final bool enableOfflineCache;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.border,
    this.backgroundColor,
    this.placeholder,
    this.errorWidget,
    this.httpHeaders,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.placeholderFadeInDuration = const Duration(milliseconds: 300),
    this.onTap,
    this.semanticsLabel,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
    this.enableOfflineCache = true, 
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Default CORS headers for web compatibility
    final Map<String, String> defaultHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': '*',
    };

    final effectiveHeaders = {
      ...defaultHeaders,
      ...(httpHeaders ?? {}),
    };

    Widget imageWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: border ?? Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        color: backgroundColor,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          httpHeaders: effectiveHeaders,
          fit: fit,
          fadeInDuration: fadeInDuration,
          placeholderFadeInDuration: placeholderFadeInDuration,
          memCacheWidth: width?.toInt(),
          memCacheHeight: height?.toInt(),
          cacheManager: enableOfflineCache 
              ? ImageCacheManager.instance 
              : null,
          placeholder: placeholder != null 
              ? (context, url) => placeholder!
              : (context, url) => _buildDefaultPlaceholder(theme),
          errorWidget: errorWidget != null
              ? (context, url, error) => errorWidget!
              : (context, url, error) => _buildDefaultErrorWidget(theme, url, error),
        ),
      ),
    );

    // Add semantics for accessibility
    if (semanticsLabel != null) {
      imageWidget = Semantics(
        label: semanticsLabel,
        child: imageWidget,
      );
    }

    // Add tap functionality if provided
    if (onTap != null) {
      imageWidget = GestureDetector(
        onTap: onTap,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildDefaultPlaceholder(ThemeData theme) {
    return Container(
      color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Loading...',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultErrorWidget(ThemeData theme, String url, dynamic error) {
    // Log error for debugging
    debugPrint('NetworkImageWidget: Failed to load image from $url - Error: $error');
    
    return Container(
      color: backgroundColor ?? theme.colorScheme.errorContainer,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: theme.colorScheme.onErrorContainer,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            'Failed to load',
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.onErrorContainer,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                error.toString().length > 50 
                    ? '${error.toString().substring(0, 47)}...'
                    : error.toString(),
                style: TextStyle(
                  fontSize: 8,
                  color: theme.colorScheme.onErrorContainer.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

// Convenience constructors for common use cases
extension NetworkImageWidgetExtensions on NetworkImageWidget {
  /// Creates a circular avatar image
  static Widget avatar({
    required String imageUrl,
    required double radius,
    Color? backgroundColor,
    Widget? placeholder,
    Widget? errorWidget,
    VoidCallback? onTap,
    String? semanticsLabel,
  }) {
    return NetworkImageWidget(
      imageUrl: imageUrl,
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(radius),
      backgroundColor: backgroundColor,
      placeholder: placeholder,
      errorWidget: errorWidget,
      onTap: onTap,
      semanticsLabel: semanticsLabel,
    );
  }

  /// Creates a thumbnail image with consistent styling
  static Widget thumbnail({
    required String imageUrl,
    double size = 80,
    BoxFit fit = BoxFit.cover,
    VoidCallback? onTap,
    String? semanticsLabel,
  }) {
    return NetworkImageWidget(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: fit,
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      semanticsLabel: semanticsLabel,
    );
  }

  /// Creates a hero image for full-width displays
  static Widget hero({
    required String imageUrl,
    double? width,
    double height = 200,
    BoxFit fit = BoxFit.cover,
    VoidCallback? onTap,
    String? semanticsLabel,
  }) {
    return NetworkImageWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      semanticsLabel: semanticsLabel,
    );
  }
}