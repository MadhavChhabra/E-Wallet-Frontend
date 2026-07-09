import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_ewallet/services/image_service.dart';
import 'package:image_picker/image_picker.dart';

class IdCardUploadPage extends StatefulWidget {
  const IdCardUploadPage({super.key});

  @override
  State<IdCardUploadPage> createState() => _IdCardUploadPageState();
}

class _IdCardUploadPageState extends State<IdCardUploadPage> {
  XFile? _image;
  Uint8List? _previewBytes;
  final picker = ImagePicker();

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      if (!mounted) return;
      setState(() {
        _image = pickedFile;
        _previewBytes = bytes;
      });
    }
  }

  Future<void> uploadImage() async {
    if (_image == null) return;
    final filename = await ImageService.uploadImage(_image!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(filename != null
            ? 'Image uploaded successfully'
            : 'Failed to upload image'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Upload')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _previewBytes == null
                ? const Text('No image selected.')
                : Image.memory(_previewBytes!, width: 200, height: 200),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: getImage,
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadImage,
              child: const Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}
