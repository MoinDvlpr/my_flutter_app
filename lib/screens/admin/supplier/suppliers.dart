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
                builder: (context, state, fetchNextPage) =>
                    PagedListView<int, SupplierModel>(
                      state: state,
                      fetchNextPage: fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate(
                        itemBuilder: (context, supplier, index) {
                          return GestureDetector(
                            onTap: () {
                              supplierController.clearControllers();
                              supplierController.supplierNameController.text = supplier.supplierName;
                              supplierController.supplierContactController.text = supplier.contact.toString();
                              Get.to(()=>AddEditSupplierScreen(supplierID: supplier.supplierId,));
                            },
                            child: Container(
                              padding: EdgeInsets.all(16.0),

                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: grey.withValues(
                                      alpha: 0.2,
                                    ),
                                    radius: 25,
                                    child: Icon(
                                      Icons.person,
                                      color: white,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      supplier.supplierName,
                                      style: AppTextStyle.regularTextstyle,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton( onPressed: () async {
                                    showDeleteConfirmationDialog(
                                      title: 'Delete supplier',
                                      message: 'Are you sure ?',
                                      onConfirm: () async {
                                        if (supplier.supplierId != null) {
                                          await supplierController
                                              .deleteSupplier(
                                            supplier.supplierId!,supplier
                                          );
                                        }
                                      },
                                    );
                                  },
                                    icon: Icon(
                                      Icons.delete_outlined,
                                      color: primary,
                                    ),
                                    tooltip: 'delete',)
                                ],
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
