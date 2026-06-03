import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ProfileImageHandler {
  static Future<File> saveProfileImage(Image image) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File newImage = File('${directory.path}/profile_image.jpg');
      if (newImage.existsSync()) {
        await newImage.delete();
      }
      await newImage.writeAsBytes(await pickedFile.readAsBytes());
      return newImage;
    } else {
      throw Exception('No image selected');
    }
  }

  static Future<Image> getProfileImage() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File imageFile = File('${directory.path}/profile_image.jpg');
    if (imageFile.existsSync()) {
      return Image.file(imageFile);
    } else {
      return Image.asset('assets/placeholder_image.jpg');
    }
  }

  
}

