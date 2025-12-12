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

                    builder: (context, state, fetchNextPage) => RefreshIndicator(
                      onRefresh: () async {
                        return categoryController.pagingController.refresh();
                      },
                      child: PagedListView<int, CategoryModel>(
                        state: state,
                        fetchNextPage: fetchNextPage,
                        builderDelegate: PagedChildBuilderDelegate(
                          itemBuilder: (context, category, index) {
                            categoryController.isCatActive[category
                                    .categoryId!] =
                                category.isActive;
                            return Obx(
                              () => Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border:
                                      index !=
                                          categoryController.categories.length -
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
                                    (categoryController.isCatActive[category
                                                .categoryId!] ??
                                            category.isActive)
                                        ? Container(
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6.0,
                                                    vertical: 2,
                                                  ),
                                              child: Text(
                                                'Active',
                                                style: AppTextStyle
                                                    .semiBoldTextstyle
                                                    .copyWith(
                                                      color: Colors.green,
                                                      fontSize: 12,
                                                    ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6.0,
                                                    vertical: 2,
                                                  ),
                                              child: Text(
                                                'Inactive',
                                                style: AppTextStyle
                                                    .semiBoldTextstyle
                                                    .copyWith(
                                                      color: Colors.red,
                                                      fontSize: 12,
                                                    ),
                                              ),
                                            ),
                                          ),

                                    PopupMenuButton(
                                      color: bg,
                                      itemBuilder: (context) {
                                        return [
                                          PopupMenuItem(
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit, color: grey),
                                                SizedBox(width: 10),
                                                Text(
                                                  'Edit',
                                                  style: AppTextStyle
                                                      .regularTextstyle,
                                                ),
                                              ],
                                            ),
                                            onTap: () async {
                                              categoryController
                                                      .categoryNameController
                                                      .text =
                                                  category.categoryName;
                                              categoryController
                                                      .isActive
                                                      .value =
                                                  categoryController
                                                      .isCatActive[category
                                                      .categoryId!] ??
                                                  category.isActive;
                                              Get.to(
                                                () => AddEditCategory(
                                                  catID: category.categoryId,
                                                ),
                                              );
                                            },
                                          ),
                                          PopupMenuItem(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete_outlined,
                                                  color: primary,
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  'Delete',
                                                  style: AppTextStyle
                                                      .regularTextstyle,
                                                ),
                                              ],
                                            ),
                                            onTap: () async {
                                              showDeleteConfirmationDialog(
                                                title: 'Delete category',
                                                message: 'Are you sure ?',
                                                onConfirm: () async {
                                                  if (category.categoryId !=
                                                      null) {
                                                    await categoryController
                                                        .deleteCategory(
                                                          id: category
                                                              .categoryId!,
                                                          index: index,
                                                        );
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                          PopupMenuItem(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  (categoryController
                                                              .isCatActive[category
                                                              .categoryId!] ??
                                                          category.isActive)
                                                      ? Icons.remove_red_eye
                                                      : Icons
                                                            .remove_red_eye_outlined,
                                                  color:
                                                      (categoryController
                                                              .isCatActive[category
                                                              .categoryId!] ??
                                                          category.isActive)
                                                      ? primary
                                                      : grey,
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  (categoryController
                                                              .isCatActive[category
                                                              .categoryId!] ??
                                                          category.isActive)
                                                      ? 'Chane to "Inactive"'
                                                      : 'Chane to "Active"',
                                                  style: AppTextStyle
                                                      .regularTextstyle,
                                                ),
                                              ],
                                            ),
                                            onTap: () async {
                                              await categoryController
                                                  .activeInactiveHandle(
                                                    id: category.categoryId!,
                                                    index: index,
                                                  );
                                            },
                                          ),
                                        ];
                                      },
                                    ),
                                    // IconButton(
                                    //   onPressed: () async {
                                    //     categoryController
                                    //             .categoryNameController
                                    //             .text =
                                    //         category.categoryName;
                                    //     Get.to(
                                    //       () => AddEditCategory(
                                    //         catID: category.categoryId,
                                    //       ),
                                    //     );
                                    //   },
                                    //   icon: Icon(Icons.edit, color: grey),
                                    //   tooltip: 'edit',
                                    // ),
                                    // IconButton(
                                    //   onPressed: () async {
                                    //     showDeleteConfirmationDialog(
                                    //       title: 'Delete category',
                                    //       message: 'Are you sure ?',
                                    //       onConfirm: () async {
                                    //         if (category.categoryId != null) {
                                    //           await categoryController
                                    //               .deleteCategory(
                                    //                 id: category.categoryId!,
                                    //                 index: index,
                                    //               );
                                    //         }
                                    //       },
                                    //     );
                                    //   },
                                    //   icon: Icon(
                                    //     Icons.delete_outlined,
                                    //     color: primary,
                                    //   ),
                                    //   tooltip: 'delete',
                                    // ),
                                  ],
                                ),
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
