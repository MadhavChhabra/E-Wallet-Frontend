import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ewallet/blocs/auth/auth_bloc.dart';

import 'package:flutter_ewallet/models/sign_up_model.dart';
import 'package:image_picker/image_picker.dart';

import '../../../blocs/auth/auth_event.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../utils/shared.dart';
import '../../../utils/theme.dart';
import '../../widgets/custom_button.dart';

class SignUpVerifyProfilePage extends StatefulWidget {
  final SignUpModel data;

  const SignUpVerifyProfilePage({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<SignUpVerifyProfilePage> createState() =>
      _SignUpVerifyProfilePageState();
}

class _SignUpVerifyProfilePageState extends State<SignUpVerifyProfilePage> {
  XFile? selectedImage;
  Uint8List? selectedBytes;

  bool validate() {
    if (selectedImage == null) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailed) {
            showCustomSnackBar(context, state.error);
          }
          if (state is AuthSuccess) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            children: [
              Container(
                width: 155,
                height: 50,
                margin: const EdgeInsets.only(top: 100, bottom: 100),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/img_logo_light.png',
                    ),
                  ),
                ),
              ),
              Text(
                'Verify Your\nAccount',
                style: blackTextStyle.copyWith(
                  fontSize: 20,
                  fontWeight: semiBold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: whiteColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Upload image
                    GestureDetector(
                      onTap: () async {
                        final image = await selectImage();
                        if (image == null) return;
                        final bytes = await image.readAsBytes();
                        setState(() {
                          selectedImage = image;
                          selectedBytes = bytes;
                        });
                      },
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: lightBackgroundColor,
                          image: selectedBytes == null
                              ? null
                              : DecorationImage(
                                  image: MemoryImage(selectedBytes!),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        child: selectedImage != null
                            ? null
                            : Center(
                                child: Image.asset(
                                  'assets/ic_upload.png',
                                  width: 32,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    Text(
                      'Passport/ID Card',
                      style: blackTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: medium,
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    CustomFilledButton(
                      title: 'Continue',
                      onPressed: () {
                        if (validate()) {
                          context.read<AuthBloc>().add(
                                AuthRegister(
                                  widget.data.copyWith(
                                    ktp: selectedBytes == null
                                        ? null
                                        : 'data:image/png;base64,+${base64Encode(selectedBytes!)}',
                                  ),
                                ),
                              );
                        } else {
                          showCustomSnackBar(
                              context, "Pictures cannot be empty!");
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              CustomTextButton(
                title: 'Skip for now',
                onPressed: () {
                  context.read<AuthBloc>().add(
                        AuthRegister(widget.data),
                      );
                },
              )
            ],
          );
        },
      ),
    );
  }
}
