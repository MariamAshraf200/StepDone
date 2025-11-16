import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/util/widgets/custom_dilog.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/plan_entity.dart';
import '../../bloc/bloc.dart';
import '../../bloc/event.dart';

class PlanImageSection extends StatelessWidget {
  final PlanDetails plan;

  const PlanImageSection({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Show a header with title and an add button and render all thumbnails
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.images,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () async {
                final picker = ImagePicker();
                try {
                  final multi = await picker.pickMultiImage();
                  if (multi.isNotEmpty) {
                    final newPaths = multi.map((e) => e.path).toList();
                    final updatedImages = List<String>.from(plan.images ?? [])..addAll(newPaths);
                    final updated = plan.copyWith(images: updatedImages);
                    context.read<PlanBloc>().add(UpdatePlanEvent(updated));
                  }
                } catch (e) {
                  // ignore image picker errors silently or log if needed
                }
              },
              icon: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
              label: Text(
                l10n.add,
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Builder(builder: (ctx) {
          final images = plan.images ?? [];
          if (images.isEmpty) {
            return Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image, size: 36, color: Colors.grey),
                ),
              ],
            );
          }

          return SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 8),
              itemCount: images.length,
              itemBuilder: (context, idx) {
                final path = images[idx];
                final file = File(path);
                final exists = file.existsSync();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (!exists) return;
                          showDialog(
                            context: ctx,
                            builder: (_) => Dialog(
                              child: InteractiveViewer(
                                child: Image.file(
                                  file,
                                  fit: BoxFit.contain,
                                  errorBuilder: (c, e, s) => Container(
                                    padding: const EdgeInsets.all(24),
                                    child: const Icon(Icons.broken_image, size: 56, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: exists
                              ? Image.file(
                                  file,
                                  width: 120,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : SizedBox(
                                  width: 120,
                                  height: 80,
                                  child: const Icon(Icons.broken_image, size: 36, color: Colors.grey),
                                ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            final confirmed = await showDialog<bool?>(
                              context: ctx,
                              builder: (dctx) => CustomDialog(
                                title: l10n.deletePlan,
                                description: l10n.deletePlanDescription,
                                operation: l10n.deleteOperation,
                                icon: Icons.delete,
                                color: Colors.red,
                                onCanceled: () => Navigator.of(dctx).pop(false),
                                onConfirmed: () => Navigator.of(dctx).pop(true),
                              ),
                            );

                            if (confirmed == true) {
                              final updated = plan.copyWith(images: List<String>.from(images)..removeAt(idx));
                              context.read<PlanBloc>().add(UpdatePlanEvent(updated));
                            }
                          },
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white.withAlpha(200),
                            child: Icon(Icons.close, size: 16, color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
            ),
          );
        }),
      ],
    );
  }
}
