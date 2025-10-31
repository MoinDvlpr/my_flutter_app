import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_textstyles.dart';
import '../../widgets/app_snackbars.dart';
import '../../widgets/appsubmitbtn.dart';

class GoogleMapScreen extends StatelessWidget {
  final AuthController controller = Get.put(AuthController());

  GoogleMapScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => GoogleMap(
                onMapCreated: controller.onMapCreated,
                initialCameraPosition: controller.initialCameraPosition,
                onTap: controller.onMapTap,
                markers: controller.selectedMarker.value != null
                    ? {controller.selectedMarker.value!}
                    : {},
              ),
            ),
          ),
          Obx(
            () => Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                controller.address.value,
                style: AppTextStyle.regularTextstyle.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GlobalAppSubmitBtn(
              title: 'Use this location',
              onTap: () {
                if (controller.selectedPosition != null) {
                  controller.setMapAddress();
                } else {
                  AppSnackbars.warning(
                    'Location not selected',
                    "Tap on the map, then press 'Use this location'.",
                  );
                }
              },
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
