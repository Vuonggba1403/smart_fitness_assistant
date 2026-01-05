import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';

/// Widget hiển thị trạng thái khi chưa có badges
///
/// Widget này được sử dụng trong [NFTCollectionScreen] để hiển thị
/// thông báo thân thiện khi người dùng chưa có bất kỳ badge nào.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon trophy lớn với màu xám
          const Icon(
            Icons.emoji_events_outlined,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),

          // Tiêu đề thông báo
          Text(
            LocaleKey.noBadgesYet.tr,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),

          // Thông điệp hướng dẫn
          Text(
            LocaleKey.completeBadgesMessage.tr,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
