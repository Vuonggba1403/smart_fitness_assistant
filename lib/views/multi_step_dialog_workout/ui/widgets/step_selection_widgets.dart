import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/models/injury.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import '../../logic/cubit/multi_step_dialog_cubit.dart';

/// ✨ Gộp 2 step phức tạp với shared components

// ========== Step 5: Food Allergies ==========
class StepFoodAllergies extends StatelessWidget {
  const StepFoodAllergies({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultiStepDialogCubit, MultiStepDialogState>(
      builder: (context, state) {
        if (state.isLoadingData) {
          return CustomCircleProgIndicator();
        }

        final cubit = context.read<MultiStepDialogCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKey.selectAllergiesInstruction.tr,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            _SearchField(
              hintText: LocaleKey.searchFood.tr,
              onChanged: cubit.filterMeals,
            ),
            const SizedBox(height: 12),
            if (state.selectedFoodAllergies.isNotEmpty)
              _SelectedChips(
                items: state.selectedFoodAllergies.toList(),
                onDelete: cubit.toggleFoodAllergy,
                getLabel: (meal) => meal.name,
                backgroundColor: Colors.red.shade100,
                iconColor: Colors.red,
              ),
            Text(
              LocaleKey.foodList.tr,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _ItemsList(
              items: state.filteredMeals,
              selectedItems: state.selectedFoodAllergies,
              onToggle: cubit.toggleFoodAllergy,
              emptyMessage: LocaleKey.noFoodFound2.tr,
              itemBuilder: (context, meal, isSelected, onToggle) {
                return ListTile(
                  dense: true,
                  leading: meal.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            meal.imageUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.restaurant, size: 20),
                        ),
                  title: Text(meal.name, style: const TextStyle(fontSize: 13)),
                  subtitle: Text(
                    '${meal.calories} cal • ${meal.category ?? LocaleKey.food.tr}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                  trailing: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? Colors.red.shade600 : Colors.grey,
                  ),
                  selected: isSelected,
                  selectedTileColor: Colors.red.shade50,
                  onTap: () => onToggle(meal),
                );
              },
            ),
            if (state.selectedFoodAllergies.isNotEmpty)
              TextButton.icon(
                onPressed: cubit.clearFoodAllergies,
                icon: const Icon(Icons.clear_all, size: 18),
                label: Text(LocaleKey.clearAll.tr),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                ),
              ),
          ],
        );
      },
    );
  }
}

// ========== Step 6: Injuries ==========
class StepInjuries extends StatelessWidget {
  const StepInjuries({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultiStepDialogCubit, MultiStepDialogState>(
      builder: (context, state) {
        if (state.isLoadingData) {
          return CustomCircleProgIndicator();
        }

        final cubit = context.read<MultiStepDialogCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKey.selectInjuriesInstruction.tr,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            _SearchField(
              hintText: LocaleKey.searchInjury.tr,
              onChanged: cubit.filterInjuries,
            ),
            const SizedBox(height: 12),
            if (state.selectedInjuries.isNotEmpty)
              _SelectedChips<Injury>(
                items: state.selectedInjuries.toList(),
                onDelete: cubit.toggleInjury,
                getLabel: (injury) => injury.localizedName,
                backgroundColor: (injury) =>
                    Injury.getSeverityColor(injury.severity).withOpacity(0.2),
                iconColor: (injury) => Injury.getSeverityColor(injury.severity),
                icon: Icons.warning,
              ),
            Text(
              LocaleKey.injuryList.tr,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _InjuriesList(
              injuries: state.filteredInjuries,
              selectedInjuries: state.selectedInjuries,
              onToggle: cubit.toggleInjury,
            ),
            if (state.selectedInjuries.isNotEmpty)
              TextButton.icon(
                onPressed: cubit.clearInjuries,
                icon: const Icon(Icons.clear_all, size: 18),
                label: Text(LocaleKey.clearAll.tr),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                ),
              ),
          ],
        );
      },
    );
  }
}

// ========== Shared Components ==========

/// Generic search field component
class _SearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.hintText, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: onChanged,
    );
  }
}

/// Generic selected chips component with flexible styling
class _SelectedChips<T> extends StatelessWidget {
  final List<T> items;
  final ValueChanged<T> onDelete;
  final String Function(T) getLabel;
  final dynamic backgroundColor; // Can be Color or Function(T)
  final dynamic iconColor; // Can be Color or Function(T)
  final IconData icon;

  const _SelectedChips({
    required this.items,
    required this.onDelete,
    required this.getLabel,
    required this.backgroundColor,
    required this.iconColor,
    this.icon = Icons.close,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final bgColor = backgroundColor is Function
                ? backgroundColor(item)
                : backgroundColor as Color;
            final icColor = iconColor is Function
                ? iconColor(item)
                : iconColor as Color;

            return Chip(
              avatar: CircleAvatar(
                backgroundColor: bgColor,
                child: Icon(icon, size: 16, color: icColor),
              ),
              label: Text(getLabel(item)),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => onDelete(item),
            );
          }).toList(),
        ),
        const Divider(height: 24),
      ],
    );
  }
}

/// Generic items list component
class _ItemsList<T> extends StatelessWidget {
  final List<T> items;
  final Set<T> selectedItems;
  final ValueChanged<T> onToggle;
  final String emptyMessage;
  final Widget Function(BuildContext, T, bool, ValueChanged<T>) itemBuilder;

  const _ItemsList({
    required this.items,
    required this.selectedItems,
    required this.onToggle,
    required this.emptyMessage,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  emptyMessage,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = selectedItems.contains(item);
                return itemBuilder(context, item, isSelected, onToggle);
              },
            ),
    );
  }
}

/// Specialized injuries list with category headers
class _InjuriesList extends StatelessWidget {
  final List<Injury> injuries;
  final Set<Injury> selectedInjuries;
  final ValueChanged<Injury> onToggle;

  const _InjuriesList({
    required this.injuries,
    required this.selectedInjuries,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: injuries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  LocaleKey.noInjuryFound2.tr,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: injuries.length,
              itemBuilder: (context, index) {
                final injury = injuries[index];
                final isSelected = selectedInjuries.contains(injury);
                final showCategoryHeader =
                    index == 0 ||
                    injuries[index - 1].category != injury.category;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showCategoryHeader)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        color: Colors.grey.withOpacity(0.1),
                        child: Text(
                          injury.localizedCategory,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Injury.getSeverityColor(
                            injury.severity,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.health_and_safety,
                          size: 20,
                          color: Injury.getSeverityColor(injury.severity),
                        ),
                      ),
                      title: Text(
                        injury.localizedName,
                        style: const TextStyle(fontSize: 13),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (Get.locale?.languageCode != 'en')
                            Text(
                              injury.nameEn,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          if (Get.locale?.languageCode != 'en')
                            const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Injury.getSeverityColor(
                                injury.severity,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              Injury.getSeverityLabel(injury.severity),
                              style: TextStyle(
                                fontSize: 10,
                                color: Injury.getSeverityColor(injury.severity),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected
                            ? Injury.getSeverityColor(injury.severity)
                            : Colors.grey,
                      ),
                      selected: isSelected,
                      selectedTileColor: Injury.getSeverityColor(
                        injury.severity,
                      ).withOpacity(0.05),
                      onTap: () => onToggle(injury),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
