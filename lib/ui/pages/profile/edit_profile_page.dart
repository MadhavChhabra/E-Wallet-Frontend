import 'package:flutter/material.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/utils/theme.dart';

/// Shows the authenticated user's profile from `/users/me`. Name and email are
/// read-only on the backend; use the linked actions for password and photo.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final res = await HttpService.getWithAuth('/users/me');
      if (!mounted) return;
      setState(() {
        _profile = res['data'] is Map ? Map<String, dynamic>.from(res['data']) : null;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: whiteColor,
            ),
            child: _loading
                ? const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _readOnlyField('Username', profile?['username']?.toString()),
                      const SizedBox(height: 12),
                      _readOnlyField('Full name', profile?['fullName']?.toString()),
                      const SizedBox(height: 12),
                      _readOnlyField('Email', profile?['email']?.toString()),
                      const SizedBox(height: 20),
                      Text(
                        'To change your password or profile photo, use the options on the Profile screen.',
                        style: greyTextStyle.copyWith(fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      CustomFilledButton(
                        title: 'Back to Profile',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyField(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: greyTextStyle.copyWith(fontSize: 12)),
        const SizedBox(height: 6),
        Text(
          value == null || value.isEmpty ? '—' : value,
          style: blackTextStyle.copyWith(fontSize: 16, fontWeight: medium),
        ),
      ],
    );
  }
}
