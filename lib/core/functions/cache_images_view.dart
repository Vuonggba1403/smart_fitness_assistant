import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';

class CacheImage extends StatelessWidget {
  const CacheImage({super.key, required this.url});

  final String url;
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      height: 300,
      fit: BoxFit.fill,
      width: double.infinity,
      placeholder: (context, url) =>
          Center(child: CircularProgressIndicator(color: TColor.primaryColor2)),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
