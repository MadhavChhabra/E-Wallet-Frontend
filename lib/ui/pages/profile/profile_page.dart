import 'package:flutter/material.dart';
import 'package:flutter_ewallet/ui/pages/forgotPassword/change_password_internal.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/custom_profile_menu_item.dart';
import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:flutter_ewallet/utils/theme.dart';

import '../../../services/http_service.dart';
import '../../../services/image_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Image _image = Image.asset("assets/placeholder_image.jpg");

  @override
  void initState() {
    super.initState();
    _fetchProfileImage();
  }

  void _logout() async {
    try {
      // Best-effort server-side revocation, then clear local credentials.
      await HttpService.logout();
      await SharedUser.logout();
      SharedUser().setProfileImage(Image.asset("assets/placeholder_image.jpg"));
      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/sign-in', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
    } catch (e) {
      // Even if the network call fails, ensure the user is logged out locally.
      await SharedUser.logout();
      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/sign-in', (route) => false);
    }
  }

  void _fetchProfileImage() async {
    try {
      final url = await ImageService.currentProfileImageUrl();
      if (url != null && mounted) {
        setState(() {
          _image = Image.network(url);
          SharedUser().setProfileImage(_image);
        });
      }
    } catch (_) {
      // Keep the existing/placeholder image.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 22,
            ),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _image.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: whiteColor,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check_circle,
                          color: greenColor,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  "${SharedUser().getFirstname()!} ${SharedUser().getLastname()}",
                  style: blackTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: medium,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                ProfileMenuItem(
                  iconUrl: 'assets/ic_edit_profile.png',
                  title: 'Edit Profile',
                  onTap: () async {
                    final routerPin = Navigator.pushNamed(context, '/pin');
                    if (await routerPin == true) {
                      // ignore: use_build_context_synchronously
                      Navigator.pushNamed(context, '/profile-edit')
                          .then((value) => setState(() {}));
                    }
                  },
                ),
                ProfileMenuItem(
                  iconUrl: 'assets/ic_pin.png',
                  title: 'My Pin',
                  onTap: () async {
                    final routerPin = Navigator.pushNamed(context, '/pin');
                    if (await routerPin == true) {
                      // ignore: use_build_context_synchronously
                      Navigator.pushNamed(context, '/edit-pin');
                    }
                  },
                ),
                ProfileMenuItem(
                  iconUrl: 'assets/ic_wallet.png',
                  title: 'Add Account',
                  onTap: () {
                    Navigator.pushNamed(context, '/addAccount')
                        .then((value) => setState(() {}));
                  },
                ),
                ProfileMenuItem(
                  iconUrl: 'assets/qr_scan.png',
                  title: 'Show QR Code',
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('/showAccountQR')
                        .then((value) => setState(() {}));
                  },
                  // ignore: use_build_context_synchronously
                ),
                ProfileMenuItem(
                  iconUrl: 'assets/edit_pic.png',
                  title: 'Edit Profile Image',
                  onTap: () async {
                    await Navigator.pushNamed(context, '/profile-image-edit');
                    if (mounted) setState(() {});
                  },
                ),
                ProfileMenuItem(
                  iconUrl: 'assets/pw_change.png',
                  title: 'Edit Password',
                  onTap: () async {
                    final routerPin = Navigator.pushNamed(context, '/pin');
                    if (await routerPin == true) {
                      final String? email = await SharedUser().getEmail();
                      if (!context.mounted) return;
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => ChangePasswordInternal(
                                  email: email.toString())))
                          .then((value) => setState(() {}));
                    }
                  },
                ),
                ProfileMenuItem(
                  iconUrl: 'assets/ic_logout.png',
                  title: 'Log Out',
                  onTap: () {
                    _logout();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          CustomTextButton(
            title: 'Report a Problem',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
