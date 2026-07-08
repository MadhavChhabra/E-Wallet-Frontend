import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Color whiteColor = const Color(0xffFFFFFF);
Color blackColor = const Color(0xff14193F);
Color greyColor = const Color(0xffA4ABAE);
Color blueColor = const Color(0xff53C1F9);
Color purpleColor = const Color(0xff5142E6);
Color redColor = const Color(0xffFF2566);
Color greenColor = const Color(0xff22B07D);
Color numberBackgroundColor = const Color(0xff1A1D2E);
Color lightBackgroundColor = const Color(0xffF6F8FB);
Color darkBackgroundColor = const Color(0xff020518);

TextStyle blackTextStyle = GoogleFonts.poppins(
  color: blackColor,
);

TextStyle whiteTextStyle = GoogleFonts.poppins(
  color: whiteColor,
);

TextStyle greyTextStyle = GoogleFonts.poppins(
  color: greyColor,
);

TextStyle blueTextStyle = GoogleFonts.poppins(
  color: blueColor,
);

TextStyle greenTextStyle = GoogleFonts.poppins(
  color: greenColor,
);

FontWeight light = FontWeight.w300;
FontWeight regular = FontWeight.w400;
FontWeight medium = FontWeight.w500;
FontWeight semiBold = FontWeight.w600;
FontWeight bold = FontWeight.w700;
FontWeight extraBold = FontWeight.w800;
FontWeight black = FontWeight.w900;

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: purpleColor,
    brightness: Brightness.light,
    surface: lightBackgroundColor,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: lightBackgroundColor,
    fontFamily: blackTextStyle.fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: lightBackgroundColor,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: blackColor),
      titleTextStyle: blackTextStyle.copyWith(
        fontSize: 20,
        fontWeight: semiBold,
      ),
    ),
    cardTheme: CardTheme(
      color: whiteColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightBackgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: greyColor.withOpacity(0.18)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: purpleColor.withOpacity(0.65), width: 1.4),
      ),
      hintStyle: greyTextStyle.copyWith(fontSize: 14),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: purpleColor,
      foregroundColor: whiteColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}
