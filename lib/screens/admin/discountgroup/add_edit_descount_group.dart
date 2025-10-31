import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../controllers/discount_group_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/appsubmitbtn.dart';
import '../../../widgets/global_textfield.dart';

class AddEditDiscountGroup extends StatelessWidget {
  AddEditDiscountGroup({super.key, this.groupID});
  final DiscountGroupController discountGroupController = Get.put(
    DiscountGroupController(),
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final int? groupID;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: Text(groupID != null ? 'Edit Group' : 'Add Group')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(height: 10),
                GlobalTextFormField(
                  label: 'Group name',
                  controller: discountGroupController.groupNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'group name is required';
                    } else {
                      return null;
                    }
                  },
                ),
                GlobalTextFormField(
                  textInputType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,}$'),
                    ),
                  ],
                  label: 'Discount percentage %',
                  controller: discountGroupController.percentageController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'this field is required';
                    } else if (double.parse(value) <= 0) {
                      return 'should be > 0';
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 32),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GlobalAppSubmitBtn(
                      title: groupID != null ? 'Save' : 'Add',
                      isLoading: discountGroupController.isLoading.value,
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          discountGroupController.addOrEditGroup(
                            groupID: groupID,
                          );
                        }
                      },
                      height: 55,
                    ),
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
