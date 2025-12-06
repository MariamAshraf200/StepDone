import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/util/date_and_time/date_sort_util.dart';
import '../../../../injection_imports.dart';
import 'plan_form_image_section.dart';


class PlanForm extends StatefulWidget {
  final PlanDetails? initialPlan;
  final bool isUpdate;

  const PlanForm({
    super.key,
    this.initialPlan,
    required this.isUpdate,
  });

  @override
  State<PlanForm> createState() => _PlanFormState();
}

class _PlanFormState extends State<PlanForm> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _planTitleController;
  late final TextEditingController _planDescriptionController;

  DateTime? _planStartDate;
  DateTime? _planEndDate;
  String? _selectedCategory;
  late TaskPriority _selectedPriority;
  final List<XFile> _pickedImages = [];
  final List<String> _initialImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate && widget.initialPlan != null) {
      _planTitleController = TextEditingController(text: widget.initialPlan!.title);
      _planDescriptionController = TextEditingController(text: widget.initialPlan!.description);
      _planStartDate = DateSortUtil.parseFlexibleDate(widget.initialPlan!.startDate);
      _planEndDate = DateSortUtil.parseFlexibleDate(widget.initialPlan!.endDate);
      _selectedCategory = widget.initialPlan!.category;
      _selectedPriority = TaskPriorityExtension.fromString(widget.initialPlan!.priority);
      _initialImages.addAll(widget.initialPlan!.images ?? []);
    } else {
      _planTitleController = TextEditingController();
      _planDescriptionController = TextEditingController();
      _planStartDate = null;
      _planEndDate = null;
      _selectedCategory = null;
      _selectedPriority = TaskPriority.medium;
    }
  }

  @override
  void dispose() {
    _planTitleController.dispose();
    _planDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final multi = await picker.pickMultiImage();
      if (multi.isNotEmpty) {
        setState(() {
          _pickedImages.addAll(multi);
        });
      }
    } catch (_) {
      // ignore errors
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: AppSpaces.calculatePaddingFromScreenWidth(context),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: 10.0),
            CustomTextField(
              isRequired: true,
              outSideTitle: l10n.planTitle,
              borderRadius: 10,
              labelText: widget.isUpdate ? l10n.updatePlanTitle : l10n.addPlanTitle,
              controller: _planTitleController,
              maxLength: 42,
              validator: (value) {
                if (value.trim().isEmpty) {
                  return l10n.planTitleRequired;
                }
                return null;
              },
            ),
            CustomTextField(
              outSideTitle: l10n.description,
              labelText: widget.isUpdate ? l10n.updatePlanDescription : l10n.addPlanDescription,
              controller: _planDescriptionController,
              maxLines: 3,
              canBeNull: true,
            ),
            DateFiled(
              onDateSelected: (selectedDate) {
                setState(() {
                  _planStartDate = selectedDate;
                });
                if (_planEndDate != null && _planStartDate != null && _planEndDate!.isBefore(_planStartDate!)) {
                  setState(() {
                    _planEndDate = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(l10n.endDateCleared)));
                }
              },
              isRequired: true,
              outSideTitle: l10n.planStartDate,
              labelText: l10n.datePlaceholder,
              suffixIcon: const Icon(Icons.date_range),
              initialDate: _planStartDate,
            ),
            const SizedBox(height: 16.0),
            DateFiled(
              onDateSelected: (selectedDate) {
                setState(() {
                  _planEndDate = selectedDate;
                });
              },
              isRequired: false,
              outSideTitle: l10n.planEndDate,
              labelText: l10n.datePlaceholder,
              suffixIcon: const Icon(Icons.date_range),
              initialDate: _planEndDate,
              firstDate: _planStartDate,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                if (_planStartDate == null) return null;
                final parsed = DateSortUtil.parseFlexibleDate(value);
                if (parsed == null) return l10n.invalidEndDate;
                if (parsed.isBefore(_planStartDate!)) return l10n.endDateBeforeStartDate;
                return null;
              },
            ),
            CategorySelectorWithLogic(
              selectedCategory: _selectedCategory,
              onCategorySelected: (selectedCategory) {
                setState(() {
                  _selectedCategory = selectedCategory;
                });
              },
            ),
            const SizedBox(height: 16.0),
            PrioritySelectorWithLogic(
              selectedPriority: _selectedPriority,
              onPrioritySelected: (p) {
                setState(() => _selectedPriority = p);
              },
            ),
            // Images picker / preview area
            PlanFormImageSection(
              initialImages: _initialImages,
              pickedImages: _pickedImages,
              onPickImage: _pickImage,
              onRemoveInitialImage: (i) => setState(() => _initialImages.removeAt(i)),
              onRemovePickedImage: (i) => setState(() => _pickedImages.removeAt(i)),
            ),
            // Save/Update Button
            LoadingElevatedButton(
              onPressed: _handleSubmit,
              buttonText: widget.isUpdate ? l10n.updatePlan : l10n.addPlan,
              icon: widget.isUpdate ? const Icon(Icons.update) : const Icon(Icons.add),
              showLoading: true,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final datePattern = l10n.dateFormat;
    final formattedStartDate = _planStartDate != null
        ? DateFormat(datePattern).format(_planStartDate!)
        : l10n.noTime;
    final formattedEndDate = _planEndDate != null
        ? DateFormat(datePattern).format(_planEndDate!)
        : l10n.noTime;

    final combined = [
      ..._initialImages,
      ..._pickedImages.map((e) => e.path),
    ];

    if (widget.isUpdate && widget.initialPlan != null) {
      final updatedPlan = widget.initialPlan!.copyWith(
        title: _planTitleController.text.trim(),
        description: _planDescriptionController.text.trim(),
        startDate: formattedStartDate,
        endDate: formattedEndDate,
        priority: _selectedPriority.toTaskPriorityString(),
        category: _selectedCategory ?? l10n.general,
        images: combined.isNotEmpty ? combined : null,
      );

      context.read<PlanBloc>().add(UpdatePlanEvent(updatedPlan));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.planUpdated)));
    } else {
      final newPlan = PlanDetails(
        id: const Uuid().v4(),
        title: _planTitleController.text.trim(),
        description: _planDescriptionController.text.trim(),
        startDate: formattedStartDate,
        endDate: formattedEndDate,
        priority: _selectedPriority.toTaskPriorityString(),
        category: _selectedCategory ?? l10n.general,
        status: 'Not Completed',
        images: combined.isNotEmpty ? combined : null,
      );

      context.read<PlanBloc>().add(AddPlanEvent(newPlan));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.planAdded)));
    }

    Navigator.of(context).pop();
  }
}
