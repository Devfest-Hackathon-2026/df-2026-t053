import 'dart:developer';
import 'dart:io';

import 'package:material_ui/material_ui.dart';

class const CluePhotoView({
  super.key,
  required final File file,
  required final String alt,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.file(
      file,
      fit: .contain,
      semanticLabel: alt,
      errorBuilder: (context, error, stackTrace) {
        log(
          '手がかり写真の表示に失敗しました',
          error: error.runtimeType,
          stackTrace: stackTrace,
        );
        return const Text('写真を表示できませんでした。', textAlign: .center);
      },
    );
  }
}
