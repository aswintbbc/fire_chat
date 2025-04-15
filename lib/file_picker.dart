import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  final void Function(String path)? onImagePicked;

  const ImagePickerWidget({super.key, this.onImagePicked});

  Future<void> _pickImage(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      onImagePicked?.call(result.files.single.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: const Icon(Icons.image),
      onTap: () => _pickImage(context),
    );
  }
}
