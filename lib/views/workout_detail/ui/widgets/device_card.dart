import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';

/// Card widget for displaying individual device/equipment
class DeviceCard extends StatelessWidget {
  final String deviceName;
  final String imageUrl;

  const DeviceCard({
    super.key,
    required this.deviceName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return Container(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: media.width * 0.35,
            width: media.width * 0.35,
            decoration: BoxDecoration(
              border: Border.all(color: TColor.primaryColor1, width: 1),
              gradient: LinearGradient(
                colors: AppTheme.gradientColors1(Get.context!),
              ),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
            ),
            alignment: Alignment.center,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: media.width * 0.2,
              height: media.width * 0.2,
              fit: BoxFit.contain,
              placeholder: (context, url) => CustomCircleProgIndicator(),
              errorWidget: (context, url, error) => Icon(
                Icons.fitness_center,
                color: textColor?.withOpacity(0.3),
                size: media.width * 0.2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: media.width * 0.35,
              child: Text(
                deviceName,
                style: TextStyle(color: textColor, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
