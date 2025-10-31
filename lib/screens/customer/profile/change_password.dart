import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/user_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/appsubmitbtn.dart';
import '../../../widgets/global_textfield.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});
  final _formKey = GlobalKey<FormState>();
  final userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: Text('Change password')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                GlobalTextFormField(
                  label: 'Old password',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'old password required';
                    } else {
                      return null;
                    }
                  },
                  controller: userController.oldPassController,
                ),

                GlobalTextFormField(
                  label: 'New password',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'new password required';
                    } else {
                      return null;
                    }
                  },
                  controller: userController.passController,
                ),
                GlobalTextFormField(
                  label: 'Repeat new password',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'repeat password required';
                    } else {
                      return null;
                    }
                  },
                  controller: userController.repassController,
                ),
                SizedBox(height: 55),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GlobalAppSubmitBtn(
                    title: 'Save password',
                    height: 55,
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        await userController.changePassword();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
