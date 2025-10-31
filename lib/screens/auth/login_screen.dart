import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_flutter_app/screens/auth/signup_screen.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_textstyles.dart';
import '../../widgets/appsubmitbtn.dart';
import '../../widgets/global_textfield.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final AuthController authController = Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Login", style: AppTextStyle.boldTextstyle),
                  SizedBox(height: 50),
                  GlobalTextFormField(
                    label: 'Email',
                    controller: authController.emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "email is required";
                      } else if (!RegExp(
                        r'^[^@]+@[^@]+\.[^@]+',
                      ).hasMatch(value)) {
                        return "enter valid email";
                      }
                      return null;
                    },
                  ),
                  GlobalTextFormField(
                    label: 'Password',
                    controller: authController.passController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "password is required";
                      } else {
                        return null;
                      }
                    },
                    obscureText: true,
                  ),
                  SizedBox(height: 50),
                  GlobalAppSubmitBtn(
                    title: 'Login',
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        authController.login();
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have account?"),
                      TextButton(
                        onPressed: () {
                          authController.clearController();
                          Get.offAll(() => SignUpScreen());
                        },
                        child: Text(
                          'Register',
                          style: AppTextStyle.lableStyle.copyWith(
                            color: primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
