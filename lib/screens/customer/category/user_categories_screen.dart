import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../controllers/category_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../model/category_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../utils/debouncer.dart';
import '../../../widgets/appbar_with_cart.dart';
import 'user_category_products_screen.dart';

class UserCategoryScreen extends StatelessWidget {
  UserCategoryScreen({super.key});

  final CategoryController categoryController = Get.find<CategoryController>();
  final ProductController productController = Get.find<ProductController>();
  final _debouncer = Debouncer(delay: Duration(milliseconds: 500));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: appBarWithCart(title: "Categories", onTap: () {}),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSearchBar(),
          ),
          Expanded(
            child: PagingListener(
              controller: categoryController.pagingController,
              builder: (context, state, fetchNextPage) =>
                  PagedListView<int, CategoryModel>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    builderDelegate: PagedChildBuilderDelegate(
                      itemBuilder: (context, category, index) =>
                          _buildCategoryTile(category),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextFormField(
      onChanged: (value) async {
        _debouncer.run(
          () => categoryController.updateSearchQuery(value.trim()),
        );
      },
      decoration: InputDecoration(
        hintText: 'Search categories...',
        prefixIcon: const Icon(Icons.search),
        contentPadding: const EdgeInsets.all(12),
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
    );
  }

  Widget _buildCategoryTile(CategoryModel category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Text(
          category.categoryName,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          Get.to(
            () =>
                UserCategoryProductScreen(categoryName: category.categoryName),
          );
          productController.catID = category.categoryId;
        },
      ),
    );
  }
}
