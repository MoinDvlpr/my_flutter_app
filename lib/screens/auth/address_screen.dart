import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../../widgets/appsubmitbtn.dart';
import '../../widgets/global_textfield.dart';
import 'google_map_screen.dart';

class AddressScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final int? addressID;
  AddressScreen({super.key, this.addressID});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: Text('Shipping Address')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlobalTextFormField(
                  controller: authController.fullNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "full name is required";
                    } else if (value.length > 60) {
                      return 'name should be less than 60 characters';
                    } else {
                      return null;
                    }
                  },
                  label: 'Full name',
                ),
                GlobalTextFormField(
                  controller: authController.contactController,
                  label: 'Mobile',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "mobile is required";
                    } else if (value.length < 10 || value.length > 10) {
                      return 'enter valid number';
                    } else {
                      return null;
                    }
                  },
                  textInputType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
                GlobalTextFormField(
                  controller: authController.addressController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "address is required";
                    } else if (value.length > 120) {
                      return 'address should be less than 120 characters';
                    } else {
                      return null;
                    }
                  },
                  label: 'Address',
                  suffixBtn: GestureDetector(
                    onTap: () async {
                      Get.to(() => GoogleMapScreen());
                      authController.address.value =
                          "Tap on map to get address";
                      authController.selectedPosition = null;
                      authController.selectedMarker.value = null;
                      await authController.fetchUserLocation();
                    },
                    child: Icon(Icons.location_on_outlined, color: grey),
                  ),
                ),
                GlobalTextFormField(
                  controller: authController.cityController,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "city is required";
                    } else if (value.length > 50) {
                      return 'city should be less than 50 characters';
                    } else {
                      return null;
                    }
                  },
                  label: 'City',
                ),
                GlobalTextFormField(
                  controller: authController.stateController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "state is required";
                    } else if (value.length > 50) {
                      return 'state should be less than 50 characters';
                    } else {
                      return null;
                    }
                  },
                  label: 'State',
                ),
                GlobalTextFormField(
                  controller: authController.countryController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "country is required";
                    } else if (value.length > 50) {
                      return 'country should be less than 50 characters';
                    } else {
                      return null;
                    }
                  },
                  label: 'Country',
                ),
                GlobalTextFormField(
                  controller: authController.zipCodeController,
                  label: 'Zip code',
                  textInputType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "zipcode is required";
                    } else if (value.length > 10) {
                      return 'zipcode should be less than 10 characters';
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 24),
                GlobalAppSubmitBtn(
                  title: 'Save Address',
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      if (addressID == null) {
                        await authController.saveAddress();
                      } else {
                        await authController.editAddress(addressID!);
                      }
                    }
                  },
                  height: 50,
                  isLoading: authController.isLoading.value,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
