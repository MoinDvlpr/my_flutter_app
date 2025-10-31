import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/product_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../widgets/appsubmitbtn.dart';
import '../home/home_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  OrderSuccessScreen({super.key});
final controller = Get.find<ProductController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Image.asset('assets/images/bags.png', height: 150, width: 150),
              SizedBox(height: 16),
              Text('Success!', style: AppTextStyle.boldTextstyle),
              Text(
                'Your order will be delivered soon.\nThank you for choosing our app!',
                style: AppTextStyle.regularTextstyle.copyWith(fontSize: 16),
              ),
              SizedBox(height: 55),
              GlobalAppSubmitBtn(
                title: 'Continue shopping!',
                onTap: () {
                  Get.offAll(() => HomeScreen());
                  controller.pagingController.refresh();

                },
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
