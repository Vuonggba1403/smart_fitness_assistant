import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';

/// ✅ CacheImage Widget - Hiển thị ảnh từ network với cache
class CacheImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CacheImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Kiểm tra URL có hợp lệ không
    if (url.isEmpty) {
      return Container(
        width: width ?? 200,
        height: height ?? 200,
        decoration: BoxDecoration(
          color: TColor.gray.withOpacity(0.2),
          borderRadius: borderRadius ?? BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.image_not_supported_outlined,
          color: TColor.gray,
          size: 40,
        ),
      );
    }

    final widget = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        color: TColor.gray.withOpacity(0.1),
        child: CustomCircleProgIndicator(),
      ),
      errorWidget: (context, url, error) => Container(
        width: width ?? 200,
        height: height ?? 200,
        color: TColor.gray.withOpacity(0.2),
        child: Icon(
          Icons.image_not_supported_outlined,
          color: TColor.gray,
          size: 40,
        ),
      ),
    );

    // ✅ Apply borderRadius nếu có
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: widget);
    }

    return widget;
  }
}
