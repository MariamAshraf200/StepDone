import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../constants/date_and_time_form.dart';

class DateFiled extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(DateTime selectedDate) onDateSelected;
  final String outSideTitle;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool isRequired;
  final bool canBeNull;

  const DateFiled({
    super.key,
    this.controller,
    required this.labelText,
    required this.onDateSelected,
    this.suffixIcon,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.outSideTitle = "",
    this.validator,
    this.isRequired = false,
    this.canBeNull = false,
  });

  @override
  State<DateFiled> createState() => _DateFiledState();
}

class _DateFiledState extends State<DateFiled> {
  late final TextEditingController _controller;
  late final bool _ownsController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize controller here because we need `context` for localized formatting
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = TextEditingController(
        text: widget.initialDate != null ? formatedDate(context, widget.initialDate!) : '',
      );
      _ownsController = true;
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 10),
            Text(
              widget.outSideTitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 5),
            if (widget.isRequired)
              Text(
                "*",
                style: TextStyle(
                  color: Colors.red[500],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: widget.initialDate ?? DateTime.now(),
              firstDate: widget.firstDate ??
                  DateTime.now().subtract(const Duration(days: 365)),
              lastDate: widget.lastDate ??
                  DateTime.now().add(const Duration(days: 365 * 10)),
            );
            if (pickedDate != null) {
              setState(() {
                _controller.text = formatedDate(context, pickedDate);
                widget.onDateSelected(pickedDate);
              });
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: _controller,
              validator: _validateInput,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                filled: true,
                labelText: widget.labelText,
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.surfaceBright,
                  ),
                ),
                suffixIcon:
                widget.suffixIcon ?? const Icon(Icons.calendar_today),
              ),
              readOnly: true,
            ),
          ),
        ),
      ],
    );
  }

  String? _validateInput(String? value) {
    if (!widget.canBeNull && (value == null || value.trim().isEmpty)) {
      final l10n = AppLocalizations.of(context)!;
      final fieldName = (widget.outSideTitle.trim().isNotEmpty) ? widget.outSideTitle : widget.labelText;
      return l10n.enterField(fieldName);
    }

    if (widget.validator == null) {
      return null;
    }
    return widget.validator!(value!.trim());
  }

}
