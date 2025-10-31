import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:get/get.dart';
import '../../../controllers/product_controller.dart';
import '../../../model/product_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';

class ProductDetail extends StatelessWidget {
  ProductDetail({super.key, required this.product});
  final ProductModel product;
  final ProductController productController = Get.put(ProductController());
  @override
  Widget build(BuildContext context) {
    List<File> images = [];

    if (product.productImage.isNotEmpty) {
      // On load from DB
      List<String> imagePaths = product.productImage.split(',');
      images = imagePaths.map((p) => File(p)).toList();
    }
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: Text('Product')),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 470,
            child: images.isEmpty
                ? Image.asset('assets/images/noimg.png')
                : ImageSlideshow(
                    isLoop: true,
                    children: images
                        .map(
                          (image) => image.existsSync()
                              ? Image.file(image, fit: BoxFit.fitWidth)
                              : Image.asset('assets/images/noimg.png'),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 16),

          /// Product Info
          Text(product.productName, style: AppTextStyle.semiBoldTextstyle),
          Text(
            product.stockQty > 0.0
                ? 'Available'
                : 'Sorry this product is not available right now!',
            style: AppTextStyle.lableStyle,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                "₹${product.price.toStringAsFixed(0)} ",
                style: AppTextStyle.semiBoldTextstyle,
              ),
            ],
          ),
          const SizedBox(height: 12),

          /// Description with read more
          Obx(() {
            final desc = product.description ?? '';
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
                    height: 1.5,
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
                        style: AppTextStyle.semiBoldTextstyle.copyWith(
                          color: primary,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
