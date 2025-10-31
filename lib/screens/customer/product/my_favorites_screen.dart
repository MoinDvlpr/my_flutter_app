import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../controllers/product_controller.dart';
import '../../../model/product_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../widgets/appbar_with_cart.dart';
import 'product_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  FavoritesScreen({super.key});
  final ProductController productController = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: appBarWithCart(title: "Favorites", onTap: () {}),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: PagingListener(
          controller: productController.pagingControllerForFavs,
          builder: (context, state, fetchNextPage) =>
              PagedListView<int, ProductModel>(
                state: state,
                fetchNextPage: fetchNextPage,
                builderDelegate: PagedChildBuilderDelegate(
                  itemBuilder: (context, product, index) =>
                      _buildProductRowCard(product, index),
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildProductRowCard(ProductModel product, int index) {
    List<File> images = [];
    if (product.productImage.isNotEmpty) {
      // On load from DB
      List<String> imagePaths = product.productImage.split(',');
      images = imagePaths.map((p) => File(p)).toList();
    }
    return InkWell(
      onTap: () async {
        if (product.productId != null) {
          Get.to(
            () => ProductDetailScreen(
              index: index,
              productId: product.productId!,
            ),
          );
          await productController.fetchProductDetails(product.productId!);
        }
      },
      child: Card(
        color: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 0.4,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: product.productImage.isEmpty
                        ? Image.asset(
                            'assets/images/noimg.png',
                            height: 80,
                            width: 100,
                            fit: BoxFit.cover,
                          )
                        : images[0].existsSync()
                        ? Image.file(
                            images[0],
                            height: 80,
                            width: 100,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/noimg.png',
                            height: 80,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.productName,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.semiBoldTextstyle.copyWith(
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 6),
                        Text(
                          '₹${product.discountedPrice?.toStringAsFixed(0)}',
                          style: AppTextStyle.semiBoldTextstyle,
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.red,
                radius: 16,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.favorite,
                    size: 16,
                    color: Colors.white,
                  ),

                  onPressed: () async {
                    // Remove from cart or list
                    await productController.removeFavorite(
                      product.productId!,
                      index: index,
                    );
                    // await productController.fetchAllFavorites();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
