import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:my_flutter_app/controllers/category_controller.dart';
import 'package:my_flutter_app/widgets/appsubmitbtn.dart';

import '../../../controllers/product_controller.dart';
import '../../../model/product_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../utils/debouncer.dart';
import '../../../widgets/confirm_dialog.dart';
import 'add_edit_product_screen.dart';
import 'product_detail.dart';

class ProductsScreen extends StatelessWidget {
  ProductsScreen({super.key});
  final productController = Get.find<ProductController>();
  final categoryController = Get.find<CategoryController>();
  final _debouncer = Debouncer(delay: Duration(microseconds: 500));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: Text('Products')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          productController.clearControllers();
          Get.to(() => AddOrEditProductScreen());
          await categoryController.fetchAllCategories();
        },
        shape: CircleBorder(),
        backgroundColor: primary,
        child: Icon(Icons.add, color: white),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SearchBar(
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    backgroundColor: WidgetStatePropertyAll(bg),
                    hintText: 'Search',
                    onChanged: (value) async {
                      _debouncer.run(
                        () => productController.updateSearchQuery(value.trim()),
                      );
                    },
                    hintStyle: WidgetStatePropertyAll(AppTextStyle.lableStyle),
                    elevation: WidgetStatePropertyAll(0.0),
                    side: WidgetStatePropertyAll(
                      BorderSide(width: 1, color: grey),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showSortBottomSheet(context);
                  },
                  icon: Icon(Icons.filter_list_alt),
                ),
              ],
            ),
            Text(
              'All products',
              style: AppTextStyle.boldTextstyle.copyWith(
                fontSize: 16,
                height: 4.0,
              ),
            ),
            Expanded(
              child: PagingListener(
                controller: productController.pagingController,
                builder: (context, state, fetchNextPage) => PagedGridView<int, ProductModel>(
                  state: state,
                  fetchNextPage: fetchNextPage,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: 0.50,
                  ),
                  padding: EdgeInsets.only(bottom: 100),
                  builderDelegate: PagedChildBuilderDelegate(
                    itemBuilder: (context, product, index) {
                      List<File> images = [];
                      if (product.productImage.isNotEmpty) {
                        // On load from DB
                        List<String> imagePaths = product.productImage.split(
                          ',',
                        );
                        images = imagePaths.map((p) => File(p)).toList();
                      }
                      return GestureDetector(
                        onTap: () async {
                          if (product.productId != null) {
                            Get.to(() => ProductDetail(product: product));
                          }
                        },
                        child: Container(
                          clipBehavior: Clip.hardEdge,

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Flexible(
                                child: product.productImage.isEmpty
                                    ? Image.asset(
                                        'assets/images/noimg.png',
                                        fit: BoxFit.cover,
                                      )
                                    : ImageSlideshow(
                                        isLoop: true,
                                        children: images
                                            .map(
                                              (image) => image.existsSync()
                                                  ? Image.file(
                                                      image,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.asset(
                                                      'assets/images/noimg.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                            )
                                            .toList(),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      product.productName,
                                      style: AppTextStyle.boldTextstyle.copyWith(
                                        fontSize:
                                            14, // Smaller font for compact layout
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      product.stockQty > 0
                                          ? '${product.stockQty} available'
                                          : 'Not available',
                                      style: AppTextStyle.semiBoldTextstyle
                                          .copyWith(
                                            fontSize:
                                                12, // Smaller font for compact layout
                                            color: product.stockQty > 0
                                                ? Colors.green
                                                : primary,
                                          ),
                                    ),
                                    SizedBox(height: 10),
                                    GlobalAppSubmitBtn(
                                      title: 'Edit',
                                      bgcolor: grey,
                                      height: 34,
                                      onTap: () async {
                                        Get.to(
                                          () => AddOrEditProductScreen(
                                            productID: product.productId!,
                                          ),
                                        );
                                        productController.clearControllers();
                                        productController
                                                .categoryNameController
                                                .text =
                                            product.categoryName ?? '';
                                        await productController
                                            .fetchProductByID(
                                              productID: product.productId!,
                                            );
                                      },
                                    ),
                                    SizedBox(height: 10),
                                    GlobalAppSubmitBtn(
                                      title: 'Delete',
                                      height: 34,
                                      onTap: () {
                                        showDeleteConfirmationDialog(
                                          onConfirm: () {
                                            if (product.productId != null) {
                                              productController.deleteProduct(
                                                id: product.productId!,
                                                index: index,
                                              );
                                            }
                                          },
                                          message: 'Are you sure ?',
                                          title: 'Delete product',
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sort by',
                style: AppTextStyle.semiBoldTextstyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                itemCount: productController.sortOptions.length,
                itemBuilder: (context, index) {
                  return Obx(() {
                    final isSelected =
                        productController.selectedSortIndex.value == index;
                    return GestureDetector(
                      onTap: () {
                        productController.onFilterSelected(index);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        color: isSelected ? Colors.red : Colors.transparent,
                        child: Text(
                          productController.sortOptions[index],
                          style: AppTextStyle.regularTextstyle.copyWith(
                            fontSize: 15,
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
