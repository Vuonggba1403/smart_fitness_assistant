import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';

class WaterAmountSelector extends StatelessWidget {
  final int selectedAmount;
  final ValueChanged<int> onAmountChanged;

  const WaterAmountSelector({
    super.key,
    required this.selectedAmount,
    required this.onAmountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chevron_left, color: TColor.white),
              const SizedBox(width: 20),
              Text(
                '${selectedAmount}ml',
                style: TextStyle(
                  color: TColor.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 20),
              Icon(Icons.chevron_right, color: TColor.white),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [100, 200, 300, 400].map((amount) {
              return _AmountButton(
                amount: amount,
                isSelected: selectedAmount == amount,
                onTap: () => onAmountChanged(amount),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AmountButton extends StatelessWidget {
  final int amount;
  final bool isSelected;
  final VoidCallback onTap;

  const _AmountButton({
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 60,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? TColor.white : TColor.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          '${amount}ml',
          style: TextStyle(
            color: isSelected ? TColor.primaryColor1 : TColor.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
