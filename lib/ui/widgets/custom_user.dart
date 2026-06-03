import 'package:flutter/material.dart';

import '../../utils/theme.dart';

class CustomUser extends StatelessWidget {
  final Image image;
  final String userName;

  const CustomUser({
    Key? key,
    required this.image,
    required this.userName,
  }) : super(key: key);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomUser &&
          runtimeType == other.runtimeType &&
          userName == other.userName;

  @override
  int get hashCode => userName.hashCode;
  // Container(
  //     margin: const EdgeInsets.only(top: 30),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Send Again',
  //           style: blackTextStyle.copyWith(
  //             fontSize: 16,
  //             fontWeight: semiBold,
  //           ),
  //         ),
  //         const SizedBox(
  //           height: 16,
  //         ),

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(top: 3, bottom: 15),
        child: Column(
          children: [
            Container(
              // width: 140,
              // height: 90,
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(20),
              //   color: whiteColor,
              // ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 50,
                    // margin: const EdgeInsets.only(right: 17),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: whiteColor,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: image.image,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    userName,
                    style: blackTextStyle.copyWith(fontWeight: medium),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
