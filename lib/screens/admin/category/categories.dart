import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:my_flutter_app/model/category_model.dart';

import '../../../../controllers/category_controller.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_textstyles.dart';
import '../../../../widgets/confirm_dialog.dart';
import '../../../utils/debouncer.dart';
import 'add_edit_category.dart';

class Categories extends StatelessWidget {
  Categories({super.key});
  final CategoryController categoryController = Get.put(CategoryController());
  final _debouncer = Debouncer(delay: Duration(milliseconds: 500));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: Text('Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          categoryController.categoryNameController.clear();
          Get.to(() => AddEditCategory());
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
            SearchBar(
              backgroundColor: WidgetStatePropertyAll(bg),
              hintText: 'Search',
              onChanged: (value) async {
                _debouncer.run(
                  () => categoryController.updateSearchQuery(value.trim()),
                );
              },
              hintStyle: WidgetStatePropertyAll(AppTextStyle.lableStyle),
              elevation: WidgetStatePropertyAll(0.0),
              side: WidgetStatePropertyAll(BorderSide(width: 1, color: grey)),
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
            ),
            Text(
              'All categories',
              style: AppTextStyle.boldTextstyle.copyWith(
                fontSize: 16,
                height: 4.0,
              ),
            ),
            Expanded(
              child:
                  // Obx(
                  //   () =>
                  PagingListener(
                    controller: categoryController.pagingController,

                    builder: (context, state, fetchNextPage) =>
                        RefreshIndicator(
                          onRefresh: () async {
                            return categoryController.pagingController
                                .refresh();
                          },
                          child: PagedListView<int, CategoryModel>(
                            state: state,
                            fetchNextPage: fetchNextPage,
                            builderDelegate: PagedChildBuilderDelegate(
                              itemBuilder: (context, category, index) {
                                return Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border:
                                        index !=
                                            categoryController
                                                    .categories
                                                    .length -
                                                1
                                        ? Border(
                                            bottom: BorderSide(
                                              width: 0.6,
                                              color: grey,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          category.categoryName ?? '',
                                          style: AppTextStyle.regularTextstyle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          categoryController
                                                  .categoryNameController
                                                  .text =
                                              category.categoryName;
                                          Get.to(
                                            () => AddEditCategory(
                                              catID: category.categoryId,
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.edit, color: grey),
                                        tooltip: 'edit',
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          showDeleteConfirmationDialog(
                                            title: 'Delete category',
                                            message: 'Are you sure ?',
                                            onConfirm: () async {
                                              if (category.categoryId != null) {
                                                await categoryController
                                                    .deleteCategory(
                                                      id: category.categoryId!,
                                                      index: index,
                                                    );
                                              }
                                            },
                                          );
                                        },
                                        icon: Icon(
                                          Icons.delete_outlined,
                                          color: primary,
                                        ),
                                        tooltip: 'delete',
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                  ),
            ),
            // ),
          ],
        ),
      ),
    );
  }
}
