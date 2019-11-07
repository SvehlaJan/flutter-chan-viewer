import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

enum AppTheme { light, dark }

class Constants {
  //routes
  static const String favoritesRoute = "favorites";
  static const String boardsRoute = "boards";
  static const String boardDetailRoute = "board/detail";
  static const String threadDetailRoute = "board/detail/thread";
  static const String galleryRoute = "board/detail/thread/gallery";
  static const String settingsRoute = "settings";
  static const String notFoundRoute = "not_found";

  static const double avatarImageSize = 100.0;
  static const double progressPlaceholderSize = 40.0;
  static const double minFlingDistance = 100.0;
  static const Widget progressIndicator = const SizedBox(width: Constants.progressPlaceholderSize, height: Constants.progressPlaceholderSize, child: CircularProgressIndicator());
  static const Widget centeredProgressIndicator = const Center(child: progressIndicator);
  static const Widget noDataPlaceholder = const Center(child: Text("No data :-("));
  static const Widget errorPlaceholder = const Center(child: Text("Error :-("));

  //strings
  static const String appName = "Chan Viewer";

  //fonts
  static const String quickFont = "Quicksand";
  static const String ralewayFont = "Raleway";
  static const String quickBoldFont = "Quicksand_Bold.otf";
  static const String quickNormalFont = "Quicksand_Book.otf";
  static const String quickLightFont = "Quicksand_Light.otf";

  //images
  static const String imageDir = "assets/images";
  static const String pkImage = "$imageDir/pk.jpg";
  static const String profileImage = "$imageDir/profile.jpg";
  static const String blankImage = "$imageDir/blank.jpg";
  static const String dashboardImage = "$imageDir/dashboard.jpg";
  static const String loginImage = "$imageDir/login.jpg";
  static const String paymentImage = "$imageDir/payment.jpg";
  static const String settingsImage = "$imageDir/setting.jpeg";
  static const String shoppingImage = "$imageDir/shopping.jpeg";
  static const String timelineImage = "$imageDir/timeline.jpeg";
  static const String verifyImage = "$imageDir/verification.jpg";

  //generic
  static const String str_error = "Error";
  static const String str_success = "Success";
  static const String str_ok = "OK";
  static const String str_forgot_password = "Forgot Password?";
  static const String str_something_went_wrong = "Something went wrong";
  static const String str_coming_soon = "Coming Soon";

  static const MaterialColor ui_kit_color = Colors.grey;

  static List<AppTheme> appThemes = [AppTheme.light, AppTheme.dark];

//colors
  static List<Color> kitGradients = [
    // new Color.fromRGBO(103, 218, 255, 1.0),
    // new Color.fromRGBO(3, 169, 244, 1.0),
    // new Color.fromRGBO(0, 122, 193, 1.0),
    Colors.blueGrey.shade800,
    Colors.black87,
  ];
  static List<Color> kitGradients2 = [Color(0xffb7ac50), Colors.orange.shade900];

  static final Random _random = new Random();

  /// Returns a random color.
  static Color next() {
    return new Color(0xFF000000 + _random.nextInt(0x00FFFFFF));
  }
}
