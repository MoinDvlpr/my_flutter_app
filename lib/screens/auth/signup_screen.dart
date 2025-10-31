import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_textstyles.dart';
import '../../widgets/appsubmitbtn.dart';
import '../../widgets/global_textfield.dart';
import 'login_screen.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});
  final AuthController authController = Get.put(AuthController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sign up", style: AppTextStyle.boldTextstyle),
                  SizedBox(height: 50),
                  GlobalTextFormField(
                    label: 'Name',
                    controller: authController.nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "user name is required";
                      } else {
                        return null;
                      }
                    },
                  ),
                  GlobalTextFormField(
                    label: 'Mobile',
                    controller: authController.contactController,
                    textInputType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'mobile is required';
                      } else if (value.length < 10 || value.length > 10) {
                        return "invalid number";
                      } else {
                        return null;
                      }
                    },
                  ),
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
                      } else {
                        return null;
                      }
                    },
                  ),
                  GlobalTextFormField(
                    label: 'Password',
                    obscureText: true,
                    controller: authController.passController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "password is required";
                      } else {
                        return null;
                      }
                    },
                  ),
                  GlobalTextFormField(
                    label: 'Re-Password',
                    controller: authController.repassController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "re-password is required";
                      } else {
                        return null;
                      }
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Already have account?'),
                      TextButton(
                        onPressed: () {
                          authController.clearController();
                          Get.offAll(() => LoginScreen());
                        },
                        child: Text(
                          'Login',
                          style: AppTextStyle.lableStyle.copyWith(
                            color: primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  Obx(
                    () => GlobalAppSubmitBtn(
                      title: 'Sign Up',
                      isLoading: authController.isLoading.value,
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          authController.signUp();
                        }
                      },
                    ),
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
