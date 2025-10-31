import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../controllers/product_controller.dart';
import '../../../model/product_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../widgets/appbar_with_cart.dart';
import '../product/product_details_screen.dart';

class UserCategoryProductScreen extends StatelessWidget {
  UserCategoryProductScreen({super.key, required this.categoryName});
  final String categoryName;
  final ProductController productController = Get.find<ProductController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: appBarWithCart(title: categoryName, onTap: () {}),
      body: PagingListener(
        controller: productController.pagingControllerForCatWiseProducts,
        builder: (context, state, fetchNextPage) =>
            PagedListView<int, ProductModel>(
              state: state,
              fetchNextPage: fetchNextPage,
              builderDelegate: PagedChildBuilderDelegate(
                itemBuilder: (context, product, index) =>
                    _buildProductCard(product),
              ),
            ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    List<File> images = [];
    if (product.productImage.isNotEmpty) {
      // On load from DB
      List<String> imagePaths = product.productImage.split(',');
      images = imagePaths.map((p) => File(p)).toList();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: product.productImage.isEmpty
              ? Image.asset(
                  'assets/images/noimg.png',
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                )
              : images[0].existsSync()
              ? Image.file(images[0], height: 70, width: 70, fit: BoxFit.cover)
              : Image.asset(
                  'assets/images/noimg.png',
                  height: 80,
                  width: 100,
                  fit: BoxFit.contain,
                ),
        ),
        title: Text(
          product.productName,
          style: AppTextStyle.semiBoldTextstyle,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),

        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => GestureDetector(
                onTap: () {
                  final productId = product.productId;
                  if (productId == null) return; // safety check

                  final isFav =
                      productController.isFavoriteProduct[productId] ??
                      product.isFavorite;

                  if (isFav) {
                    productController.removeFavorite(productId);
                  } else {
                    productController.addToFavorite(productId);
                  }
                },
                child: Icon(
                  productController.isFavoriteProduct[product.productId] ??
                          product.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color:
                      productController.isFavoriteProduct[product.productId] ??
                          product.isFavorite
                      ? Colors.red
                      : Colors.grey,
                  size: 20,
                ),
              ),
            ),
            Text(
              "₹${product.price.toStringAsFixed(0)}",
              style: AppTextStyle.semiBoldTextstyle,
            ),
          ],
        ),
        onTap: () async {
          if (product.productId != null) {
            Get.to(() => ProductDetailScreen(productId: product.productId!));
            await productController.fetchProductDetails(product.productId!);
          }
        },
      ),
    );
  }
}
