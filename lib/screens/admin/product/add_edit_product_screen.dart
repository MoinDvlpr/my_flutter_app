import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controllers/category_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../model/category_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../utils/debouncer.dart';
import '../../../widgets/appsubmitbtn.dart';
import '../../../widgets/global_image_picker.dart';
import '../../../widgets/global_textfield.dart';
import '../../../widgets/search_dropdown_with_pagination.dart';

class AddOrEditProductScreen extends StatelessWidget {
  AddOrEditProductScreen({super.key, this.productID});
  final int? productID;
  final ProductController productController = Get.put(ProductController());
  final CategoryController categoryController = Get.find<CategoryController>();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final _dbouncer = Debouncer(delay: Duration(milliseconds: 500));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(productID != null ? 'Edit Product' : 'Add Product'),
      ),
      body: Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlobalTextFormField(
                  label: 'Product name',
                  controller: productController.productNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "this field is required";
                    }
                    return null;
                  },
                ),
                Visibility(
                  visible: productID == null,
                  child: GlobalTextFormField(
                    label: "Cost price",
                    controller: productController.productCostPriceController,
                    textInputType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    validator: (value) {
                      if (productID == null &&
                          (value == null || value.isEmpty)) {
                        return "this field is required";
                      } else if (productID == null &&
                          (double.parse(value!) <= 0)) {
                        return 'market price must be grater than 0';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                GlobalTextFormField(
                  label: "Product price",
                  controller: productController.productPriceController,
                  textInputType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "this field is required";
                    } else if (double.parse(value) <= 0) {
                      return 'price must be grater than 0';
                    } else {
                      return null;
                    }
                  },
                ),
                GlobalTextFormField(
                  label: "Market price",
                  controller: productController.marketPriceController,
                  textInputType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "this field is required";
                    } else if (double.parse(value) <= 0) {
                      return 'market price must be grater than 0';
                    } else {
                      return null;
                    }
                  },
                ),
                Visibility(
                  visible: productID == null,
                  child: GlobalTextFormField(
                    label: "Stock qty",
                    controller: productController.productStockController,
                    textInputType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    validator: (value) {
                      if (productID == null &&
                          (value == null || value.isEmpty)) {
                        return "this field is required";
                      } else if (productID == null && int.parse(value!) <= 0) {
                        return 'stock must be grater than 0';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),

                GlobalTextFormField(
                  readOnly: true,
                  controller: productController.categoryNameController,
                  onTap: () async {
                    Get.bottomSheet(
                      CustomSearchDropdown<CategoryModel>(
                        title: 'Category',
                        searchController:
                            productController.categorySearchController,

                        isLoading: categoryController.isLoading,
                        itemLabel: (cat) => cat.categoryName ?? '',
                        onItemSelected: (cat) {
                          productController.setCategoryID = cat.categoryId!;
                          productController.categoryNameController.text =
                              cat.categoryName;
                        },

                        onSearch: (val) {
                          _dbouncer.run(
                            () => categoryController.updateSearchQuery(val),
                          );
                        },
                        pagingController: categoryController.pagingController,
                      ),

                      backgroundColor: Colors.white,
                      isScrollControlled: true,
                    );
                  },
                  label: 'Select Category',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Category is required';
                    }
                    return null;
                  },
                ),

                // TypeAheadField<CategoryModel>(
                //   controller: productController.categoryNameController,
                //   itemBuilder: (context, category) {
                //     return Container(padding: EdgeInsets.all(8.0),child: Text(category.categoryName,style: AppTextStyle.regularTextstyle.copyWith(fontSize: 18),));
                //   },
                //   onSelected: (category) {
                //     productController.setCategoryID = category.categoryId;
                //     productController.categoryNameController.text =
                //         category.categoryName;
                //   },
                //   suggestionsCallback: (search) async {
                //     await categoryController.fetchAllCategories();
                //     if (search.isNotEmpty) {
                //       return categoryController.categories
                //           .where(
                //             (cat) => cat.categoryName
                //                 .toString()
                //                 .toLowerCase()
                //                 .contains(search.toString().toLowerCase()),
                //           )
                //           .toList();
                //     } else {
                //      return categoryController.categories
                //           ;
                //     }
                //   },
                //   builder: (context, controller, focusNode) =>
                //       GlobalTextFormField(
                //         focusNode: focusNode,
                //          readOnly: true,
                //         controller: productController.categoryNameController,
                //         onTap: () async {
                //           await categoryController.fetchAllCategories(isInitial: true);
                //
                //           Get.bottomSheet(
                //             Obx(   ()=>      CustomSearchDropdown<CategoryModel>(
                //               title: 'Customer',
                //               searchController: productController.categorySearchController,
                //               items: categoryController.categories,
                //               isLoading: categoryController.isLoading,
                //               fetchItems: categoryController.fetchAllCategories,
                //               itemLabel: (cat) => cat.categoryName ?? '',
                //               onItemSelected: (cat) {
                //                 productController.setCategoryID = cat.categoryId!;
                //                 productController.categoryNameController.text = cat.categoryName;
                //               },
                //               currentPage: categoryController.currentPage.value,
                //               totalPages: categoryController.totalPages.value,
                //               onSearch: (val) {
                //                 categoryController.searchQuery = val;
                //               },
                //             )),
                //             backgroundColor: Colors.white,
                //             isScrollControlled: true,
                //           );
                //         },
                //         label: 'Select Category',
                //         validator: (value) {
                //           if (value == null || value.trim().isEmpty) {
                //             return 'Category is required';
                //           } else if (!categoryController.categories.any((cat) =>
                //           cat.categoryName.toLowerCase() == value.toLowerCase())) {
                //             return 'Please select a valid category from the list';
                //           }
                //           return null;
                //         },
                //       ),
                // ),
                SizedBox(height: 10),
                GlobalTextFormField(
                  label: 'description',
                  maxlines: 4,
                  controller: productController.productDescController,
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Product image', style: AppTextStyle.lableStyle),
                ),
                SizedBox(height: 10),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 100,
                          width: 200,
                          child: ImagePickerOptions(
                            onTap: () {
                              productController.pickMultipleImages();
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        productController.selectedImages.isEmpty
                            ? Text('No Image selected!')
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Obx(
                  () => Visibility(
                    visible: productController.selectedImages.isNotEmpty,
                    child: SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: productController.selectedImages.length,
                        itemBuilder: (context, index) {
                          var image = productController.selectedImages[index];
                          return Stack(
                            children: [
                              Container(width: 110),
                              image.existsSync()
                                  ? Image.file(image, height: 120)
                                  : Image.asset(
                                      'assets/images/noimg.png',
                                      fit: BoxFit.cover,
                                    ),
                              Positioned(
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      productController.selectedImages.removeAt(
                                        index,
                                      );
                                    },
                                    child: Icon(
                                      Icons.clear_sharp,
                                      color: white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GlobalAppSubmitBtn(
                      height: 55,
                      title: productID != null ? 'Save' : "Add",
                      isLoading: productController.isLoading.value,
                      onTap: () async {
                        if (_formkey.currentState!.validate()) {
                          await productController.addOrEditProduct(
                            productID: productID,
                          );
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
