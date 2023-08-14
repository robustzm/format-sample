import 'package:croppy/src/src.dart';
import 'package:flutter/material.dart';

class MaterialAspectRatioBottomSheet extends StatelessWidget {
  const MaterialAspectRatioBottomSheet({super.key, required this.controller});

  final MaterialCroppableImageController controller;

  String _convertAspectRatioToString(CropAspectRatio? aspectRatio) {
    if (aspectRatio == null) {
      return 'Free';
    }

    final width = aspectRatio.width;
    final height = aspectRatio.height;

    final imageSize = controller.data.imageSize;

    if ((width == imageSize.width && height == imageSize.height) ||
        (width == imageSize.height && height == imageSize.width)) {
      return 'Original';
    }

    if (aspectRatio.isSquare) {
      return 'Square';
    }

    return '$width:$height';
  }

  List<CropAspectRatio?> get aspectRatiosToDisplay {
    final aspectRatios = controller.allowedAspectRatios;
    final cleanedAspectRatios = <CropAspectRatio?>[];

    for (final ar in aspectRatios) {
      if (ar == null) {
        cleanedAspectRatios.add(ar);
        continue;
      }

      final complement = ar.complement;

      if (aspectRatios.contains(complement)) {
        final isHorizontal = ar.isHorizontal;

        if (isHorizontal && !cleanedAspectRatios.contains(ar)) {
          cleanedAspectRatios.add(ar);
        } else if (!isHorizontal && !cleanedAspectRatios.contains(complement)) {
          cleanedAspectRatios.add(complement);
        }
      } else {
        cleanedAspectRatios.add(ar);
      }
    }

    return cleanedAspectRatios;
  }

  bool get canFlipToComplement {
    final currentAspectRatio = controller.currentAspectRatio;

    if (currentAspectRatio == null) {
      return false;
    }

    if (currentAspectRatio.isSquare) {
      return false;
    }

    final complement = currentAspectRatio.complement;
    return controller.allowedAspectRatios.contains(complement);
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = controller.currentAspectRatio;
    return SingleChildScrollView(
      child: Column(
        children: [
          ...aspectRatiosToDisplay.map(
            (v) => ListTile(
              title: Text(_convertAspectRatioToString(v)),
              selected: v == aspectRatio || v?.complement == aspectRatio,
              onTap: () {
                controller.currentAspectRatio = v;
                Navigator.of(context).pop();
              },
            ),
          ),
          if (canFlipToComplement)
            ListTile(
              title: Text(
                'Flip to ${aspectRatio!.isHorizontal ? 'vertical' : 'horizontal'}',
              ),
              onTap: () {
                controller.currentAspectRatio =
                    controller.currentAspectRatio!.complement;
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
