import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../controllers/category_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../model/category_model.dart';
import '../../../model/product_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../utils/debouncer.dart';
import '../../../widgets/appbar_with_cart.dart';
import 'product_details_screen.dart';

class UserProductsScreen extends StatelessWidget {
  UserProductsScreen({super.key});

  final productController = Get.find<ProductController>();
  final categoryController = Get.find<CategoryController>();
  final Debouncer _debouncer = Debouncer(delay: Duration(milliseconds: 500));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: appBarWithCart(title: "Home", onTap: () {}),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            _buildSearchBar(),
            SizedBox(height: 8.0),
            _buildFilterChips(),
            SizedBox(height: 8.0),
            GestureDetector(
              child: _buildFilterBar(),
              onTap: () {
                showSortBottomSheet(context);
              },
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: PagingListener(
                  controller: productController.pagingController,
                  builder: (context, state, fetchNextPage) =>
                      PagedGridView<int, ProductModel>(
                        state: state,
                        fetchNextPage: fetchNextPage,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 0,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.59,
                            ),
                        builderDelegate: PagedChildBuilderDelegate(
                          itemBuilder: (context, product, index) =>
                              GestureDetector(
                                onTap: () async {
                                  if (product.productId != null) {
                                    Get.to(
                                      () => ProductDetailScreen(
                                        productId: product.productId!,
                                      ),
                                    );
                                    await productController.fetchProductDetails(
                                      product.productId!,
                                    );
                                  }
                                },
                                child: _buildProductCard(product, index),
                              ),
                        ),
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
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sort by',
                style: AppTextStyle.regularTextstyle.copyWith(fontSize: 16),
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
                        Get.back(); // This should now work to close the bottom sheet
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
        ),
      ),
      isScrollControlled:
          true, // Allows the bottom sheet to adjust to content size
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextFormField(
        onChanged: (value) async {
          _debouncer.run(() {
            productController.search(value.trim());
          },);

        },
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: Icon(Icons.search),
          contentPadding: EdgeInsets.all(12),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: PagingListener(
        controller: categoryController.pagingController,
        builder: (context, state, fetchNextPage) =>
            PagedListView<int, CategoryModel>(
              state: state,
              fetchNextPage: fetchNextPage,
              scrollDirection: Axis.horizontal,
              builderDelegate: PagedChildBuilderDelegate(
                itemBuilder: (context, category, index) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Obx(
                    () => FilterChip(
                      label: Text(category.categoryName),
                      selected: productController.chipSelected[index] ?? false,
                      onSelected: (bool value) {
                        productController.onChipSelected(
                          category.categoryId,
                          index,
                          value,
                        );
                      },
                      selectedColor: primary,
                      checkmarkColor: white,
                      labelStyle: AppTextStyle.regularTextstyle.copyWith(
                        color: productController.chipSelected[index] ?? false
                            ? white
                            : black,
                      ),
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.filter_list),
          const SizedBox(width: 8),
          Text("Filters"),
          Spacer(),
          Obx(
            () => Text(
              productController.sortOptions[productController
                  .selectedSortIndex
                  .value],
            ),
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, int index) {
    List<File> images = [];
    if (product.productImage.isNotEmpty) {
      // On load from DB
      List<String> imagePaths = product.productImage.split(',');
      images = imagePaths.map((p) => File(p)).toList();
    }
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: product.productImage.isEmpty
                    ? Image.asset('assets/images/noimg.png', fit: BoxFit.fill)
                    : ImageSlideshow(
                        isLoop: true,
                        children: images
                            .map(
                              (image) => image.existsSync()
                                  ? Image.file(image, fit: BoxFit.cover)
                                  : Image.asset(
                                      'assets/images/noimg.png',

                                      fit: BoxFit.cover,
                                    ),
                            )
                            .toList(),
                      ),
              ),
              if (product.discountPercentage != null)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "-${product.discountPercentage}%",
                      style: AppTextStyle.regularTextstyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: Obx(
                  () => GestureDetector(
                    onTap: () {
                      if (product.productId != null) {
                        if (productController.isFavoriteProduct[product
                                .productId] ??
                            product.isFavorite) {
                          productController.removeFavorite(product.productId!);
                        } else {
                          productController.addToFavorite(product.productId!);
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        productController.isFavoriteProduct[product
                                    .productId] ??
                                product.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 18,
                        color:
                            productController.isFavoriteProduct[product
                                    .productId] ??
                                product.isFavorite
                            ? primary
                            : grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  product.productName,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.semiBoldTextstyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  "₹${product.discountedPrice?.toStringAsFixed(0)}",
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: AppTextStyle.semiBoldTextstyle,
                ),
              ),
              if (product.discountPercentage != null) ...[
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "₹${product.price.toStringAsFixed(0)}",
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    style: AppTextStyle.semiBoldTextstyle.copyWith(
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
