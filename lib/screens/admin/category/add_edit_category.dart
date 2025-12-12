import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/category_controller.dart';
import '../../../../utils/app_colors.dart';
import '../../../../widgets/appsubmitbtn.dart';
import '../../../../widgets/global_textfield.dart';

class AddEditCategory extends StatelessWidget {
  AddEditCategory({super.key, this.catID});
  final CategoryController categoryController = Get.put(CategoryController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final int? catID;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(catID != null ? 'Edit Category' : 'Add Category'),
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
                  label: 'Category name',
                  controller: categoryController.categoryNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'category name is required';
                    } else {
                      return null;
                    }
                  },
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
                              categoryController.isActive.value
                                  ? Colors.green
                                  : primary,
                            ),
                            inactiveThumbColor: white,
                            value: categoryController.isActive.value,
                            thumbIcon: WidgetStatePropertyAll(
                              categoryController.isActive.value
                                  ? Icon(Icons.check, color: Colors.green)
                                  : Icon(Icons.close, color: primary),
                            ),
                            onChanged: (bool val) {
                              categoryController.toggleActive(val);
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
                    title: catID != null ? 'Save' : 'Add',
                    isLoading: categoryController.isLoading.value,
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        categoryController.addOrEditCategory(categoryID: catID);
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
