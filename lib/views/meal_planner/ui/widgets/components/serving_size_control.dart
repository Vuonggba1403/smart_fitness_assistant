import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';

/// 🔧 Serving size control component
class ServingSizeControl extends StatelessWidget {
  final int servingSize;
  final Function(int) onUpdateServingSize;
  final Function(int) onSetServingSize;

  const ServingSizeControl({
    super.key,
    required this.servingSize,
    required this.onUpdateServingSize,
    required this.onSetServingSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              LocaleKey.customServing.tr,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => onUpdateServingSize(-10),
                  icon: const Icon(Icons.remove, size: 20),
                ),
                SizedBox(
                  width: 60,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: '$servingSize')
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: '$servingSize'.length),
                      ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      final intValue = int.tryParse(value);
                      if (intValue != null) {
                        onSetServingSize(intValue);
                      }
                    },
                  ),
                ),
                IconButton(
                  onPressed: () => onUpdateServingSize(10),
                  icon: const Icon(Icons.add, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'gram',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
