import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_flutter_app/utils/app_constant.dart';
import 'package:my_flutter_app/utils/app_textstyles.dart';
import 'package:my_flutter_app/utils/permission_handle_service.dart';
import 'controllers/auth_controller.dart';
import 'dbservice/db_helper.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/customer/home/home_screen.dart';
import 'utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // intialize stripe with publishable key
  Stripe.publishableKey =
      "pk_test_51SdOtz5oAT1cyUg4kL0ZPFv3mTjB3u16IcLtML5UkZtk2dRatYeRr8JzQWvlNlntyZXplALWDZLtXos9cGrzBfho00nsV2pblI";

  //Load our .env file that contains our Stripe Secret key
  await dotenv.load(fileName: "assets/.env");

  await DatabaseHelper.instance.database;

  await GetStorage.init();

  await PermissionHandler.requestPermission();

  Get.put(AuthController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    GetStorage storage = GetStorage();
    bool isLoggedIn = storage.read(IS_LOGGED_IN) ?? false;
    return GetMaterialApp(
      title: 'My flutter app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: bg,
          centerTitle: true,
          scrolledUnderElevation: 0.0,
          titleTextStyle: AppTextStyle.semiBoldTextstyle.copyWith(
            color: black,
            fontSize: 18,
          ),
        ),
        actionIconTheme: ActionIconThemeData(
          backButtonIconBuilder: (context) =>
              Icon(Icons.arrow_back_ios, size: 22),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: primary),
          ),
          fillColor: white,
          filled: true,
          hintStyle: AppTextStyle.regularTextstyle,
          labelStyle: AppTextStyle.lableStyle,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: isLoggedIn
          ? storage.read(ROLE) == "admin"
                ? AdminDashboard()
                : HomeScreen()
          : SignUpScreen(),
    );
  }
}
