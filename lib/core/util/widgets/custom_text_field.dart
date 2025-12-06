import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../functions/string_manipulations_and_search.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.labelText = "",
    this.outSideTitle = "",
    this.maxLines = 1,
    this.maxLength = 200,
    this.canBeNull = false,
    this.enabled = true,
    this.active = true,
    this.onChanged,
    this.onSaved,
    this.validator,
   this.borderRadius = 8.0,
    this.isRequired = false// Default border radius  /// the comment
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? outSideTitle;
  final int maxLines;
  final int maxLength ;
  final bool canBeNull;
  final bool enabled;
  final bool isRequired;
  final bool active;
  final void Function(String value)? onChanged;
  final void Function(String value)? onSaved;
  final String? Function(String value)? validator;
  final double borderRadius;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  TextDirection _stringTextDirection = getDirectionalityOf("");

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Row(
           crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 10),
            Text("${widget.outSideTitle}", style:  TextStyle(color: Theme.of(context).colorScheme.primary
                ,fontWeight: FontWeight.bold, fontSize: 16),),
            const SizedBox(width: 5),
            if(widget.isRequired)
            Text("*", style:  TextStyle(color: Colors.red[500]
                ,fontWeight: FontWeight.bold, fontSize: 16),),
          ],
        ),

        const SizedBox(height: 10),
        TextFormField(
          controller: widget.controller,
          maxLength: widget.maxLength,
          decoration: InputDecoration(
            filled: true,
            labelText: widget.labelText,
            labelStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
             borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:  BorderSide(color: Theme.of(context).colorScheme.surfaceBright),
            ),
          ),

          textDirection: _stringTextDirection,
          maxLines: widget.maxLines,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (value) {
            setState(() {
              _stringTextDirection = getDirectionalityOf(value);
            });

            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
          validator: _validateInput,
          onSaved: widget.onSaved == null
              ? null
              : (value) => widget.onSaved!(value!.trim()),
          readOnly: !widget.enabled,
          enabled: widget.active,
        ),
      ],
    );
  }

  String? _validateInput(String? value) {
    if (!widget.canBeNull && (value == null || value.trim().isEmpty)) {
      final l10n = AppLocalizations.of(context)!;
      final fieldName = (widget.outSideTitle != null && widget.outSideTitle!.trim().isNotEmpty)
          ? widget.outSideTitle!.trim()
          : (widget.labelText ?? '');
      return l10n.enterField(fieldName);
    }

    if (widget.validator == null) {
      return null;
    }

    return widget.validator!(value!.trim());
  }
}
