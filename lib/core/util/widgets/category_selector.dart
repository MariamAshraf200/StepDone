import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
class CategorySelector extends StatefulWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String>? onCategorySelected;
  final VoidCallback? onAddCategory;
  final ValueChanged<String>? onDeleteCategory;

  const CategorySelector({
    super.key,
    required this.categories,
    this.selectedCategory,
    this.onCategorySelected,
    this.onAddCategory,
    this.onDeleteCategory,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  String? _selectedCategoryInternal;

  @override
  void initState() {
    super.initState();
    _selectedCategoryInternal = widget.selectedCategory;
  }

  @override
  void didUpdateWidget(covariant CategorySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategory != oldWidget.selectedCategory) {
      setState(() => _selectedCategoryInternal = widget.selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: widget.categories.map((name) {
            final isSelected = _selectedCategoryInternal == name;
            return InputChip(
              label: Text(name),
              selected: isSelected,
              onSelected: (_) => _handleCategorySelected(name),
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: widget.onDeleteCategory == null ? null : () => widget.onDeleteCategory!(name),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Text(
          l10n.category,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: widget.onAddCategory,
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.addNew, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  void _handleCategorySelected(String categoryName) {
    setState(() => _selectedCategoryInternal = categoryName);
    widget.onCategorySelected?.call(categoryName);
  }
}
