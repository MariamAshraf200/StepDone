import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../injection_imports.dart';

class PlanFiltersWidget extends StatelessWidget {
  final String? selectedCategory;
  final PlanStatus? selectedStatus;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<PlanStatus?> onStatusChanged;

  const PlanFiltersWidget({
    super.key,
    required this.selectedCategory,
    required this.selectedStatus,
    required this.onCategoryChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    // Reusable text style for dropdown items using the theme primary color.
    final itemTextStyle = TextStyle(color: colorScheme.primary);
    return Row(
      children: [
        Expanded(
          child: BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              // Build items using canonical stored keys for `value` and localized labels for display.
              final items = <DropdownMenuItem<String>>[];
              items.add(DropdownMenuItem<String>(value: null, child: Text(l10n.allCategories, style: itemTextStyle)));
              if (state is CategoryLoaded) {
                for (final c in state.categories) {
                  final canonical = c.categoryName.toLowerCase();
                  final display = canonical == 'general' ? l10n.general : c.categoryName;
                  items.add(DropdownMenuItem<String>(
                    value: canonical == 'general' ? 'general' : c.categoryName,
                    child: Text(display, style: itemTextStyle),
                  ));
                }
              }

              return _FilterDropdown<String>(
                icon: Icon(Icons.folder, color: colorScheme.secondary),
                value: selectedCategory,
                hint: l10n.selectCategory,
                items: items,
                onChanged: onCategoryChanged,
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _FilterDropdown<PlanStatus>(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            value: selectedStatus,
            hint: l10n.selectStatus,
            items: [
              DropdownMenuItem<PlanStatus>(value: null, child: Text(l10n.allStatuses, style: itemTextStyle)),
              ...PlanStatus.values.where((status) => status != PlanStatus.all).map(
                (status) => DropdownMenuItem<PlanStatus>(
                  value: status,
                  child: Text(status.localized(context), style: itemTextStyle),
                ),
              ),
            ],
            onChanged: onStatusChanged,
          ),
        ),
      ],
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  final Widget icon;
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _FilterDropdown({
    required this.icon,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(20), blurRadius: 5)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<T>(
              value: value,
              hint: Text(
                hint,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              isExpanded: true,
              underline: const SizedBox(),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
