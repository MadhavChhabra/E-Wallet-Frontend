import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

import '../../../models/user_model.dart';
import '../../../utils/shared_user.dart';
import '../../../utils/shared_values.dart';

class ID_CardUploadPage extends StatefulWidget {
  const ID_CardUploadPage({super.key});

  @override
  _ID_CardUploadPageState createState() => _ID_CardUploadPageState();
}

class _ID_CardUploadPageState extends State<ID_CardUploadPage> {
  File? _image;
  final picker = ImagePicker();

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Read the image file
      final File file = File(pickedFile.path);

      // Decode the image
      final decodedImage = img.decodeImage(await file.readAsBytes());

      // // Define the crop dimensions
      // final width = decodedImage!.width;
      // final height = decodedImage.height;
      // final targetWidth = width;
      // final targetHeight = (width * 2 / 3).toInt();
      // final startX = 0;
      // final startY = (height - targetHeight) ~/ 2;

      // // Crop the image
      // final croppedImage = img.copyCrop(decodedImage,
      //     x: startX, height: targetHeight, width: targetWidth, y: startY);

      // // Encode the cropped image to a file
      // final croppedFile = File('${file.parent.path}/cropped_image.jpg')
      //   ..writeAsBytesSync(img.encodeJpg(croppedImage));

      setState(() {
        _image = file;
      });
    }
  }

   Future<Map<String, dynamic>> _sendImageToAPI(File imageFile) async {
 int? userId;
      final UserModel? user = await SharedUser().getCurrentUser();
      if (user != null) {
        print('User is not null');
        userId = user.id;
      }    final apiUrl =
        '${SharedValues.baseUrl}/image/user/$userId/profile-picture';
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));
    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      // If image upload successful, save the image in SharedUser


      setState(() {
        // _image = Image.file(newFile);
      });
    }
    return {'success': response.statusCode == 200};
  }

Future<void> uploadImage() async {
    if (_image == null) return;
 int? userId;
      final UserModel? user = await SharedUser().getCurrentUser();
      if (user != null) {
        print('User is not null');
        userId = user.id;
      }
    String apiUrl = '${SharedValues.baseUrl}/image/user/$userId/cards';
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    try {
      var streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        // Image uploaded successfully
        print('Image uploaded successfully');
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully'),
          ),
        );
      } else {
        print('Failed to upload image');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? const Text('No image selected.')
                : Image.file(
                    _image!,
                    width: 200,
                    height: 200,
                  ),
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
