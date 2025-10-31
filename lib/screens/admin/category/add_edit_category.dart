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
