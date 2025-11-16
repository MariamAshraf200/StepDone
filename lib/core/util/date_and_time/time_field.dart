import 'package:StepDone/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// class TimeField extends StatefulWidget {
//   final TextEditingController? controller;
//   final String labelText;
//   final Widget? suffixIcon;
//   final String? Function(String?)? validator;
//   final void Function(TimeOfDay selectedTime) onTimeSelected;
//   final String outSideTitle;
//   final TimeOfDay? initialTime;
//   final bool isRequired;
//
//   const TimeField({
//     super.key,
//     this.controller,
//     required this.labelText,
//     required this.onTimeSelected,
//     this.suffixIcon,
//     this.initialTime,
//     this.outSideTitle = "",
//     this.validator,
//     this.isRequired = false,
//   });
//
//   @override
//   State<TimeField> createState() => _TimeFieldState();
// }
//
// class _TimeFieldState extends State<TimeField> {
//   late final TextEditingController _controller = widget.controller ??
//       TextEditingController(
//         // text: _formatTime(widget.initialTime ?? TimeOfDay.now()),
//       );
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             const SizedBox(width: 10),
//             Text(
//               widget.outSideTitle,
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.primary,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(width: 5),
//             if (widget.isRequired)
//               Text(
//                 "*",
//                 style: TextStyle(
//                   color: Colors.red[500],
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 10),
//         GestureDetector(
//           onTap: () {
//             widget.onTimeSelected;
//           },
//           child: TextFormField(
//             controller: _controller,
//             validator: widget.validator,
//             decoration: InputDecoration(
//               floatingLabelBehavior: FloatingLabelBehavior.never,
//               filled: true,
//               labelText: widget.labelText,
//               labelStyle: const TextStyle(color: Colors.grey),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(5),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(
//                   color: Theme.of(context).colorScheme.surfaceBright,
//                 ),
//               ),
//               suffixIcon: IconButton(
//                 icon: widget.suffixIcon ?? const Icon(Icons.access_time),
//                 onPressed: () async {
//                   TimeOfDay? pickedTime = await showTimePicker(
//                     context: context,
//                     initialTime: widget.initialTime ?? TimeOfDay.now(),
//                   );
//                   if (pickedTime != null) {
//                     _controller.text = _formatTime(pickedTime);
//                     widget.onTimeSelected(pickedTime);
//                   }
//                 },
//               ),
//             },
//             readOnly: true,
//           ),
//         ),
//       ],
//     );
//   }
//
//   String _formatTime(TimeOfDay time) {
//     final now = DateTime.now();
//     final dateTime = DateTime(
//       now.year,
//       now.month,
//       now.day,
//       time.hour,
//       time.minute,
//     );
//     return DateFormat('hh:mm a').format(dateTime);
//   }
// }
class TimeField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(TimeOfDay selectedTime) onTimeSelected;
  final String outSideTitle;
  final TimeOfDay? initialTime;
  final bool isRequired;
  final bool canBeNull;
  final TimeOfDay? startTime;
  // New callback: notify parent about validation errors (null = no error)
  final void Function(String?)? onValidationChanged;

  const TimeField({
    super.key,
    this.controller,
    required this.labelText,
    required this.onTimeSelected,
    this.suffixIcon,
    this.initialTime,
    this.outSideTitle = "",
    this.validator,
    this.isRequired = false,
    this.canBeNull = false,
    this.startTime,
    this.onValidationChanged,
  });

  @override
  State<TimeField> createState() => _TimeFieldState();
}

class _TimeFieldState extends State<TimeField> {
  late final TextEditingController _controller = widget.controller ??
      TextEditingController(
        text: widget.initialTime != null
            ? _formatTime(widget.initialTime!)
            : '',
      );

  void _validateAndSelectTime(TimeOfDay selectedTime) {
    if (widget.startTime != null &&
        selectedTime.hour * 60 + selectedTime.minute <
            widget.startTime!.hour * 60 + widget.startTime!.minute) {
      // Don't use SnackBar here. Notify parent about the validation error so it
      // can show the message inline below the row.
      widget.onValidationChanged?.call(context.l10n.endBeforeStart);
    } else {
      // Clear any previous validation error
      widget.onValidationChanged?.call(null);
      _controller.text = _formatTime(selectedTime); // Update the text field
      widget.onTimeSelected(selectedTime);
    }
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
            final selectedTime = await showTimePicker(
              context: context,
              initialTime: widget.initialTime ?? TimeOfDay.now(),
            );

            if (selectedTime != null) {
              // ✅ لو فيه startTime معناها إن ده حقل End Time
              if (widget.startTime != null) {
                _validateAndSelectTime(selectedTime);
              } else {
                // ✅ ده الـ Start Time، فبنحدثه مباشرة بدون مقارنة
                // Also clear any validation error on start selection
                widget.onValidationChanged?.call(null);
                _controller.text = _formatTime(selectedTime);
                widget.onTimeSelected(selectedTime);
              }
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
                    widget.suffixIcon ?? const Icon(Icons.access_time),
              ),
              readOnly: true,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.jm(locale).format(dateTime);
  }

  String? _validateInput(String? value) {
    if (!widget.canBeNull && (value == null || value.trim().isEmpty)) {
      return context.l10n.enterTime;
    }

    if (widget.validator == null) {
      return null;
    }

    return widget.validator!(value!.trim());
  }
}
