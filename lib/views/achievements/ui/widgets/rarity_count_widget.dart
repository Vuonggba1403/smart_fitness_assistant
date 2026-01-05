import 'package:flutter/material.dart';

/// Widget hiển thị số lượng badges theo một loại rarity cụ thể
///
/// Hiển thị một box có màu sắc đại diện cho rarity level
/// với số lượng badges ở giữa và label bên dưới.
class RarityCountWidget extends StatelessWidget {
  /// Label hiển thị tên của rarity (Common, Rare, Epic, Legendary)
  final String label;

  /// Số lượng badges thuộc rarity này
  final int count;

  /// Màu sắc đại diện cho rarity level
  final Color color;

  const RarityCountWidget({
    Key? key,
    required this.label,
    required this.count,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Box hiển thị số lượng với màu nền của rarity
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Label tên rarity
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
