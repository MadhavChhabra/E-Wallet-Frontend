import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/utils/ImageHandler.dart';
import 'package:flutter_ewallet/utils/shared_values.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:http/http.dart' as http;

import '../../../models/user_model.dart';

class EditProfileImagePage extends StatefulWidget {
  const EditProfileImagePage({Key? key}) : super(key: key);

  @override
  _EditProfileImagePageState createState() => _EditProfileImagePageState();
}

class _EditProfileImagePageState extends State<EditProfileImagePage> {
  Image? _image;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _fetchProfileImage();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
        _image = Image.file(_imageFile!);
      });
    }
  }

  Future<void> _saveImage() async {
    if (_imageFile != null) {
      final response = await _sendImageToAPI(_imageFile!);
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick an image first'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _sendImageToAPI(File imageFile) async {
    int? userId;
    final UserModel? user = await SharedUser().getCurrentUser();
    if (user != null) {
      print('User is not null');
      userId = user.id;
    }
    final apiUrl = '${SharedValues.baseUrl}/image/user/$userId/profile-picture';
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));
    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      // If image upload successful, save the image in SharedUser
      var newFile =
          await ProfileImageHandler.saveProfileImage(Image.file(imageFile));

      setState(() {
        _imageFile = newFile;
        _image = Image.file(newFile);
      });
    }
    return {'success': response.statusCode == 200};
  }

  Future<void> _fetchProfileImage() async {
    int? userId;
    final UserModel? user = await SharedUser().getCurrentUser();
    if (user != null) {
      print('User is not null');
      userId = user.id;
    }
    final apiUrl = '${SharedValues.baseUrl}/image/user/$userId/profile-picture';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('REsponse from fetching image is $response');
      if (response.statusCode == 200) {
        final imageData = response.bodyBytes;
        setState(() {
          _image = Image.memory(imageData);
        });
      }
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile Image'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                    image: _image != null
                        ? DecorationImage(
                            image: _image!.image,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _image == null
                      ? const Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CustomFilledButton(
                onPressed: _saveImage,
                title: 'Save Image',
                                width: 200,

              ),
            ],
          ),
        ],
      ),
    );
  }
}
