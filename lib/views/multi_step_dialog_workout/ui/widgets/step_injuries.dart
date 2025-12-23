import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/models/injury.dart';
import '../../logic/cubit/multi_step_dialog_cubit.dart';

/// Widget cho Step 6: Chọn injuries
class StepInjuries extends StatelessWidget {
  const StepInjuries({super.key});

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
            const Text(
              'Chọn các vấn đề chấn thương bạn đang gặp phải:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            _buildSearchField(cubit),
            const SizedBox(height: 12),
            if (state.selectedInjuries.isNotEmpty)
              _buildSelectedChips(state, cubit),
            const Text(
              'Danh sách chấn thương:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildInjuriesList(state, cubit),
            if (state.selectedInjuries.isNotEmpty)
              TextButton.icon(
                onPressed: cubit.clearInjuries,
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Xóa tất cả'),
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
        hintText: 'Tìm chấn thương...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: cubit.filterInjuries,
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
          children: state.selectedInjuries.map((injury) {
            return Chip(
              avatar: CircleAvatar(
                backgroundColor: Injury.getSeverityColor(
                  injury.severity,
                ).withOpacity(0.2),
                child: Icon(
                  Icons.warning,
                  size: 16,
                  color: Injury.getSeverityColor(injury.severity),
                ),
              ),
              label: Text(injury.name),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => cubit.toggleInjury(injury),
            );
          }).toList(),
        ),
        const Divider(height: 24),
      ],
    );
  }

  /// Build injuries list
  Widget _buildInjuriesList(
    MultiStepDialogState state,
    MultiStepDialogCubit cubit,
  ) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: state.filteredInjuries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Không tìm thấy chấn thương',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: state.filteredInjuries.length,
              itemBuilder: (_, index) {
                final injury = state.filteredInjuries[index];
                final isSelected = state.selectedInjuries.contains(injury);
                final showCategoryHeader =
                    index == 0 ||
                    state.filteredInjuries[index - 1].category !=
                        injury.category;

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
                        color: Colors.grey.shade100,
                        child: Text(
                          injury.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
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
                        injury.name,
                        style: const TextStyle(fontSize: 13),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            injury.nameEn,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
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
                      onTap: () => cubit.toggleInjury(injury),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
