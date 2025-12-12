import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controllers/supplier_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/appsubmitbtn.dart';
import '../../../widgets/global_textfield.dart';

class AddEditSupplierScreen extends StatelessWidget {
  AddEditSupplierScreen({super.key, this.supplierID});
  final int? supplierID;
  final controller = Get.find<SupplierController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(supplierID != null ? 'Edit Supplier' : 'Add Supplier'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(height: 10),
                GlobalTextFormField(
                  label: 'Supplier name',
                  controller: controller.supplierNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'supplier name is required';
                    } else {
                      return null;
                    }
                  },
                ),
                GlobalTextFormField(
                  controller: controller.supplierContactController,
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
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Text('Active ?'),
                      SizedBox(width: 4.0),
                      Transform.scale(
                        scale: 0.7,
                        child: Obx(
                          () => Switch(
                            trackColor: WidgetStatePropertyAll(
                              controller.isActive.value
                                  ? Colors.green
                                  : primary,
                            ),
                            inactiveThumbColor: white,
                            value: controller.isActive.value,
                            thumbIcon: WidgetStatePropertyAll(
                              controller.isActive.value
                                  ? Icon(Icons.check, color: Colors.green)
                                  : Icon(Icons.close, color: primary),
                            ),
                            onChanged: (bool val) {
                              controller.toggleActive(val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Obx(
                  () => GlobalAppSubmitBtn(
                    title: supplierID != null ? 'Save' : 'Add',
                    isLoading: controller.isLoading.value,
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        controller.addEditSupplier(supplierID: supplierID);
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
