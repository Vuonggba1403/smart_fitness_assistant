import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/multi_step_dialog_cubit.dart';

/// Widget cho Step 5: Chọn food allergies
class StepFoodAllergies extends StatelessWidget {
  const StepFoodAllergies({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultiStepDialogCubit, MultiStepDialogState>(
      builder: (context, state) {
        if (state.isLoadingData) {
          return const Center(child: CircularProgressIndicator());
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
            _buildSearchField(cubit),
            const SizedBox(height: 12),
            if (state.selectedFoodAllergies.isNotEmpty)
              _buildSelectedChips(state, cubit),
            Text(
              LocaleKey.foodList.tr,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildMealsList(context, state, cubit),
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

  /// Build search field
  Widget _buildSearchField(MultiStepDialogCubit cubit) {
    return TextField(
      decoration: InputDecoration(
        hintText: LocaleKey.searchFood.tr,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: cubit.filterMeals,
    );
  }

  /// Build selected chips
  Widget _buildSelectedChips(
    MultiStepDialogState state,
    MultiStepDialogCubit cubit,
  ) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.selectedFoodAllergies.map((meal) {
            return Chip(
              avatar: CircleAvatar(
                backgroundColor: Colors.red.shade100,
                child: const Icon(Icons.close, size: 16, color: Colors.red),
              ),
              label: Text(meal.name),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => cubit.toggleFoodAllergy(meal),
            );
          }).toList(),
        ),
        const Divider(height: 24),
      ],
    );
  }

  /// Build meals list
  Widget _buildMealsList(
    BuildContext context,
    MultiStepDialogState state,
    MultiStepDialogCubit cubit,
  ) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: state.filteredMeals.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  LocaleKey.noFoodFound2.tr,
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
              itemCount: state.filteredMeals.length,
              itemBuilder: (_, index) {
                final meal = state.filteredMeals[index];
                final isSelected = state.selectedFoodAllergies.contains(meal);

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
                  onTap: () => cubit.toggleFoodAllergy(meal),
                );
              },
            ),
    );
  }
}
