import 'package:flutter/material.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/utils/shared.dart';

import '../../../utils/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final firstnameController = TextEditingController(text: '');
  final lastnameController = TextEditingController(text: '');
  final usernameController = TextEditingController(text: '');
  final emailController = TextEditingController(text: '');
  final passwordController = TextEditingController(text: '');

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    final firstname = firstnameController.text.trim();
    final lastname = lastnameController.text.trim();
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (firstname.length < 3 ||
        lastname.length < 3 ||
        username.length < 3 ||
        email.length < 6 ||
        password.length < 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Names and username need at least 3 characters; password at least 6.'),
        ),
      );
      return;
    }

    try {
      await HttpService.postWithoutAuth('/auth/signup', {
        'firstName': firstname,
        'lastName': lastname,
        'email': email,
        'username': username,
        'password': password,
        'roles': ['ROLE_USER'],
      });

      if (!mounted) return;
      Navigator.pushNamed(context, '/sign-in');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Sign up successful! Please log in to proceed.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', '').isNotEmpty
                ? e.toString().replaceFirst('Exception: ', '')
                : 'Sign up failed',
          ),
        ),
      );
    }
  }

  bool validate() {
    if (firstnameController.text.isEmpty ||
        lastnameController.text.isEmpty ||
        usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
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
          'Join Us to Unlock\nYour Growth',
          style: blackTextStyle.copyWith(
            fontSize: 20,
            fontWeight: semiBold,
          ),
        ),        const SizedBox(
          height: 20,
        ),
        _textFieldSection(context),

        
        const SizedBox(
          height: 100,
        ),
      ],
    ));
  }

  Widget _textFieldSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: whiteColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            title: 'First name',
            controller: firstnameController,
            hintText: "Enter First Name",

          ),
          const SizedBox(
            height: 12,
          ),
          CustomTextField(
            title: 'Last name',
            controller: lastnameController,
                        hintText: "Enter Last Name",

          ),
          const SizedBox(
            height: 12,
          ),
          CustomTextField(
            title: 'User name',
            controller: usernameController,
                        hintText: "Enter Username",

          ),
          const SizedBox(
            height: 12,
          ),
          CustomTextField(
            title: 'Email address',
            controller: emailController,
                        hintText: "Enter Email Address",

          ),
          const SizedBox(
            height: 12,
          ),
          CustomTextField(
            title: 'Password',
            obscureText: true,
            controller: passwordController,
                        hintText: "Enter Password",

          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/forgotPasswordEnterMail');
              },
              child: Text(
                'Forgot Password',
                style: blueTextStyle,
              ),
            ),
          ),
          CustomFilledButton(
            title: 'Continue',
            onPressed: () {
              if (validate()) {
                signUp();
              } else {
                showCustomSnackBar(context, "Please fill in all the fields");
              }
            },
          ),
                    const SizedBox(
            height: 12,
          ),
          CustomTextButton(
          title: 'Sign in',
          onPressed: () {
            Navigator.pushNamed(context, '/sign-in');
          },
        ),
        ],
      ),
    );
  }
}
