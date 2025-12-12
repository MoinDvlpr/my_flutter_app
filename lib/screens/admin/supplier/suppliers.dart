import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../controllers/discount_group_controller.dart';
import '../../../controllers/supplier_controller.dart';
import '../../../model/supplier_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../utils/debouncer.dart';
import '../../../widgets/confirm_dialog.dart';
import 'add_edit_supplier_screen.dart';
import 'supplier_info_screen.dart';

class SuppliersScreen extends StatelessWidget {
  SuppliersScreen({super.key});
  final supplierController = Get.find<SupplierController>();
  final discountGroupController = Get.find<DiscountGroupController>();
  final _debouncer = Debouncer(delay: Duration(milliseconds: 500));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Suppliers')),
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          supplierController.clearControllers();
          Get.to(() => AddEditSupplierScreen());
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
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              backgroundColor: WidgetStatePropertyAll(bg),
              hintText: 'Search',
              onChanged: (value) async {
                _debouncer.run(
                  () => supplierController.updateSearchQuery(value.trim()),
                );
              },
              hintStyle: WidgetStatePropertyAll(AppTextStyle.lableStyle),
              elevation: WidgetStatePropertyAll(0.0),
              side: WidgetStatePropertyAll(BorderSide(width: 1, color: grey)),
            ),
            Text(
              'All Suppliers',
              style: AppTextStyle.boldTextstyle.copyWith(
                fontSize: 16,
                height: 4.0,
              ),
            ),
            Expanded(
              child: PagingListener(
                builder: (context, state, fetchNextPage) => PagedListView<int, SupplierModel>(
                  state: state,
                  fetchNextPage: fetchNextPage,
                  builderDelegate: PagedChildBuilderDelegate(
                    itemBuilder: (context, supplier, index) {
                      supplierController.isSupplierActive[supplier
                              .supplierId!] =
                          supplier.isActive;
                      return Obx(
                        () => GestureDetector(
                          onTap: () async {
                            // Navigate to Supplier Info Screen
                            supplierController.supplierID =
                                supplier.supplierId!;
                            Get.to(
                              () => SupplierInfoScreen(supplier: supplier),
                            );
                            await supplierController.fetchSupplierStats(
                              supplier.supplierId!,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: grey.withValues(alpha: 0.2),
                                  radius: 25,
                                  child: Icon(
                                    Icons.business,
                                    color: primary,
                                    size: 30,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        supplier.supplierName,
                                        style: AppTextStyle.regularTextstyle,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        supplier.contact.toString(),
                                        style: AppTextStyle.lableStyle.copyWith(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                (supplierController.isSupplierActive[supplier
                                            .supplierId!] ??
                                        supplier.isActive)
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
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
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
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
                                              style:
                                                  AppTextStyle.regularTextstyle,
                                            ),
                                          ],
                                        ),
                                        onTap: () async {
                                          supplierController.clearControllers();
                                          supplierController
                                                  .supplierNameController
                                                  .text =
                                              supplier.supplierName;
                                          supplierController
                                              .supplierContactController
                                              .text = supplier.contact
                                              .toString();
                                          supplierController.isActive.value =
                                              supplierController
                                                  .isSupplierActive[supplier
                                                  .supplierId!] ??
                                              supplier.isActive;
                                          Get.to(
                                            () => AddEditSupplierScreen(
                                              supplierID: supplier.supplierId,
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
                                              style:
                                                  AppTextStyle.regularTextstyle,
                                            ),
                                          ],
                                        ),
                                        onTap: () async {
                                          showDeleteConfirmationDialog(
                                            title: 'Delete supplier',
                                            message: 'Are you sure ?',
                                            onConfirm: () async {
                                              if (supplier.supplierId != null) {
                                                await supplierController
                                                    .deleteSupplier(
                                                      supplier.supplierId!,
                                                      supplier,
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
                                              (supplierController
                                                          .isSupplierActive[supplier
                                                          .supplierId!] ??
                                                      supplier.isActive)
                                                  ? Icons.remove_red_eye
                                                  : Icons
                                                        .remove_red_eye_outlined,
                                              color:
                                                  (supplierController
                                                          .isSupplierActive[supplier
                                                          .supplierId!] ??
                                                      supplier.isActive)
                                                  ? primary
                                                  : grey,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              (supplierController
                                                          .isSupplierActive[supplier
                                                          .supplierId!] ??
                                                      supplier.isActive)
                                                  ? 'Chane to "Inactive"'
                                                  : 'Chane to "Active"',
                                              style:
                                                  AppTextStyle.regularTextstyle,
                                            ),
                                          ],
                                        ),
                                        onTap: () async {
                                          // for change active/inactive status
                                          await supplierController
                                              .activeInactiveSupplierHandle(
                                                id: supplier.supplierId!,
                                                index: index,
                                                val:
                                                    !(supplierController
                                                            .isSupplierActive[supplier
                                                            .supplierId!] ??
                                                        supplier.isActive),
                                              );
                                        },
                                      ),
                                    ];
                                  },
                                ),
                                // Row(
                                //   mainAxisSize: MainAxisSize.min,
                                //   children: [
                                //     IconButton(
                                //       onPressed: () {
                                //         supplierController.clearControllers();
                                //         supplierController
                                //                 .supplierNameController
                                //                 .text =
                                //             supplier.supplierName;
                                //         supplierController
                                //             .supplierContactController
                                //             .text = supplier.contact
                                //             .toString();
                                //         Get.to(
                                //           () => AddEditSupplierScreen(
                                //             supplierID: supplier.supplierId,
                                //           ),
                                //         );
                                //       },
                                //       icon: Icon(
                                //         Icons.edit_outlined,
                                //         color: primary,
                                //         size: 20,
                                //       ),
                                //       tooltip: 'edit',
                                //     ),
                                //     IconButton(
                                //       onPressed: () async {
                                //         showDeleteConfirmationDialog(
                                //           title: 'Delete supplier',
                                //           message: 'Are you sure ?',
                                //           onConfirm: () async {
                                //             if (supplier.supplierId != null) {
                                //               await supplierController
                                //                   .deleteSupplier(
                                //                     supplier.supplierId!,
                                //                     supplier,
                                //                   );
                                //             }
                                //           },
                                //         );
                                //       },
                                //       icon: Icon(
                                //         Icons.delete_outlined,
                                //         color: Colors.red,
                                //         size: 20,
                                //       ),
                                //       tooltip: 'delete',
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                controller: supplierController.pagingController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
