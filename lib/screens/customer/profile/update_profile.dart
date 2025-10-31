import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../controllers/user_controller.dart';
import '../../../widgets/appsubmitbtn.dart';
import '../../../widgets/global_textfield.dart';

class UpdateProfileScreen extends StatelessWidget {
  UpdateProfileScreen({super.key});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Profile')),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                      radius: 60,
                    ),
                  ),
                  SizedBox(height: 20),
                  GlobalTextFormField(
                    label: 'Name',
                    controller: userController.nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "user name is required";
                      } else {
                        return null;
                      }
                    },
                  ),
                  GlobalTextFormField(
                    label: 'Contact',
                    controller: userController.contactController,
                    textInputType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'contact is required';
                      } else if (value.length < 10 || value.length > 10) {
                        return "invalid number";
                      } else {
                        return null;
                      }
                    },
                  ),
                  GlobalTextFormField(
                    label: 'Email',
                    controller: userController.emailController,
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

                  SizedBox(height: 50),
                  Obx(
                    () => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GlobalAppSubmitBtn(
                        height: 55,
                        title: 'Save changes',
                        isLoading: userController.isLoading.value,
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            userController.updateProfile();
                          }
                        },
                      ),
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
