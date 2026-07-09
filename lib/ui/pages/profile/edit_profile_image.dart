import 'package:flutter/material.dart';
import 'package:flutter_ewallet/services/image_service.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileImagePage extends StatefulWidget {
  const EditProfileImagePage({super.key});

  @override
  State<EditProfileImagePage> createState() => _EditProfileImagePageState();
}

class _EditProfileImagePageState extends State<EditProfileImagePage> {
  ImageProvider? _image;
  XFile? _pickedFile;

  @override
  void initState() {
    super.initState();
    _fetchProfileImage();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _pickedFile = picked;
        _image = MemoryImage(bytes);
      });
    }
  }

  Future<void> _saveImage() async {
    if (_pickedFile == null) {
      _snack('Please pick an image first', Colors.red);
      return;
    }
    final ok = await ImageService.uploadAndSetProfileImage(_pickedFile!);
    if (!mounted) return;
    _snack(ok ? 'Image saved successfully' : 'Failed to save image',
        ok ? Colors.green : Colors.red);
  }

  Future<void> _fetchProfileImage() async {
    try {
      final url = await ImageService.currentProfileImageUrl();
      if (url != null && mounted) {
        setState(() => _image = NetworkImage(url));
      }
    } catch (_) {
      // Keep the placeholder if the profile image can't be loaded.
    }
  }

  void _snack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile Image')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          Column(
            children: [
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                    image: _image != null
                        ? DecorationImage(image: _image!, fit: BoxFit.cover)
                        : null,
                  ),
                  child: _image == null
                      ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
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
