import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../l10n/app_localizations.dart';
class PlanFormImageSection extends StatelessWidget {
  final List<String> initialImages;
  final List<XFile> pickedImages;
  final VoidCallback onPickImage;
  final void Function(int) onRemoveInitialImage;
  final void Function(int) onRemovePickedImage;

  const PlanFormImageSection({
    super.key,
    required this.initialImages,
    required this.pickedImages,
    required this.onPickImage,
    required this.onRemoveInitialImage,
    required this.onRemovePickedImage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.images, style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: onPickImage,
              icon: Icon(Icons.add,),
              label: Text(
                l10n.pickPlanImage,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // If there are no images at all, show a single placeholder so the user knows
                // they can add images from this form.
                if (initialImages.isEmpty && pickedImages.isEmpty)
                  Container(
                    width: 120,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, size: 36, color: Colors.grey),
                  ),

                // initial stored images (editable)
                if (initialImages.isNotEmpty)
                  for (var i = 0; i < initialImages.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          Builder(builder: (ctx) {
                            final path = initialImages[i];
                            if (path.trim().isEmpty) {
                              return Container(
                                width: 120,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.image, size: 36, color: Colors.grey),
                              );
                            }

                            final file = File(path);
                            final exists = file.existsSync();

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
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
                            );
                          }),

                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => onRemoveInitialImage(i),
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.white.withAlpha(200),
                                child: Icon(Icons.close, size: 16, color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                // newly picked images
                if (pickedImages.isNotEmpty)
                  for (var i = 0; i < pickedImages.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(pickedImages[i].path),
                              width: 120,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => SizedBox(
                                width: 120,
                                height: 80,
                                child: const Icon(Icons.broken_image, size: 36, color: Colors.grey),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -6,
                            top: -6,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => onRemovePickedImage(i),
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.close, size: 16, color: Theme.of(context).colorScheme.primary),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
