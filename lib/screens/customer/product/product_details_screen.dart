import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:get/get.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../widgets/appbar_with_cart.dart';
import '../../../widgets/appsubmitbtn.dart';

class ProductDetailScreen extends StatelessWidget {
  ProductDetailScreen({super.key, required this.productId, this.index});

  final int productId;
  final int? index;
  final ProductController productController = Get.find<ProductController>();
  final CartController cartController = Get.find<CartController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: appBarWithCart(title: 'Product'),
      bottomNavigationBar: Obx(
        () => Padding(
          padding: const EdgeInsets.all(12),
          child: productController.stockQty.value > 0.0
              ? GlobalAppSubmitBtn(
                  title: 'ADD TO CART',
                  height: 50,
                  onTap: () async {
                    await productController.addToCart(productID: productId);
                    await cartController.fetchAllCartItems();
                  },
                )
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: primary.withValues(alpha: 0.4),
                  ),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Out of stock',
                        style: AppTextStyle.semiBoldTextstyle.copyWith(
                          color: white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
      body: Obx(() {
        List<File> images = [];
        if (productController.productImage.isNotEmpty) {
          // On load from DB
          List<String> imagePaths = productController.productImage.value.split(
            ',',
          );
          images = imagePaths.map((p) => File(p)).toList();
        }
        return productController.isLoading.value
            ? Center(child: CircularProgressIndicator(color: primary))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      SizedBox(
                        height: 500,
                        child: images.isEmpty
                            ? Image.asset('assets/images/noimg.png')
                            : ImageSlideshow(
                                isLoop: true,
                                children: images
                                    .map(
                                      (image) => image.existsSync()
                                          ? Image.file(image, fit: BoxFit.cover)
                                          : Image.asset(
                                              'assets/images/noimg.png',
                                            ),
                                    )
                                    .toList(),
                              ),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: GestureDetector(
                          onTap: () async {
                            if (productController
                                    .isFavoriteProduct[productId] ??
                                productController.isFavorite.value) {
                              productController.removeFavorite(
                                productId,
                                index: index,
                              );
                            } else {
                              productController.addToFavorite(
                                productId,
                                index: index,
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              productController.isFavoriteProduct[productId] ??
                                      productController.isFavorite.value
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  productController
                                          .isFavoriteProduct[productId] ??
                                      productController.isFavorite.value
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible:
                            productController.discountPercentage.value > 0.0,
                        child: Positioned(
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
                              "-${productController.discountPercentage.value}%",
                              style: AppTextStyle.semiBoldTextstyle.copyWith(
                                color: white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  /// Product Info
                  Text(
                    productController.productName.value,
                    style: AppTextStyle.semiBoldTextstyle,
                  ),
                  Text(
                    productController.stockQty.value > 0.0
                        ? 'Available'
                        : 'Sorry this product is not available right now!',
                    style: AppTextStyle.lableStyle,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        "₹${productController.discountedPrice.value.toStringAsFixed(0)} ",
                        style: AppTextStyle.semiBoldTextstyle,
                      ),
                      Visibility(
                        visible:
                            productController.discountPercentage.value > 0.0,
                        child: Text(
                          "₹${productController.price.value.toStringAsFixed(0)}",
                          style: AppTextStyle.lableStyle.copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  /// Description with read more
                  Obx(() {
                    final desc = productController.productDesc.value;
                    const trimLength = 650;

                    final showReadMore = desc.length > trimLength;
                    final displayText =
                        productController.isExpanded.value || !showReadMore
                        ? desc
                        : '${desc.substring(0, trimLength)}...';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayText,
                          style: AppTextStyle.regularTextstyle.copyWith(
                            fontSize: 14,
                          ),
                        ),
                        if (showReadMore)
                          GestureDetector(
                            onTap: productController.onExpanded,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                productController.isExpanded.value
                                    ? 'Read less'
                                    : 'Read more',
                                style: AppTextStyle.regularTextstyle.copyWith(
                                  color: primary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              );
      }),
    );
  }
}
