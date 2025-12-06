import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../feature/taskHome/presintation/bloc/catogeryBloc/CatogeryBloc.dart';
import '../../../feature/taskHome/presintation/bloc/catogeryBloc/Catogeryevent.dart';
import '../../../feature/taskHome/presintation/bloc/catogeryBloc/Catogerystate.dart';
import '../../../feature/taskHome/data/model/categoryModel.dart';
import '../../../l10n/app_localizations.dart';
import 'category_selector.dart';

/// Core widget that bundles UI (core CategorySelector) with Feature Bloc wiring.
/// Use this when you want the selector to load categories and dispatch add/delete
/// events automatically. Keeps form code very small.
class CategorySelectorWithLogic extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String>? onCategorySelected;

  const CategorySelectorWithLogic({
    super.key,
    this.selectedCategory,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        List<String> names = [l10n.general];
        if (state is CategoryLoaded) {
          names = state.categories
              .map((c) => c.categoryName.toLowerCase() == 'general' ? l10n.general : c.categoryName)
              .toList();
        }

        // Convert incoming canonical selectedCategory into its displayed label
        final displaySelected = (selectedCategory?.toLowerCase() == 'general')
            ? l10n.general
            : selectedCategory;

        return CategorySelector(
          categories: names,
          selectedCategory: displaySelected,
          onCategorySelected: (displayName) {
            final canonical = (displayName == l10n.general) ? 'general' : displayName;
            onCategorySelected?.call(canonical);
          },
          onAddCategory: () async {
            final controller = TextEditingController();
            final result = await showDialog<String>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(l10n.addCategory),
                content: TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: l10n.categoryName),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.cancel)),
                  TextButton(onPressed: () => Navigator.of(ctx).pop(controller.text.trim()), child: Text(l10n.add)),
                ],
              ),
            );

            if (result != null && result.isNotEmpty) {
              context.read<CategoryBloc>().add(AddCategoryEvent(categoryName: result));
            }
          },
          onDeleteCategory: (name) {
            if (state is CategoryLoaded) {
              // `name` is the displayed label (localized). Map it back to the canonical stored key.
              final model = state.categories.firstWhere(
                (c) {
                  final canonical = c.categoryName.toLowerCase();
                  // If the stored key is 'general', the displayed name will be localized (e.g. l10n.general)
                  if (canonical == 'general' && name == l10n.general) return true;
                  return c.categoryName == name;
                },
                orElse: () => CategoryModel(id: '', categoryName: ''),
              );
              if (model.id.isNotEmpty) {
                context.read<CategoryBloc>().add(DeleteCategoryEvent(id: model.id));
              }
            }
          },
        );
      },
    );
  }
}
