import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:my_flutter_app/widgets/appsubmitbtn.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/purchase_order_controller.dart';
import '../../../controllers/supplier_controller.dart';
import '../../../model/product_model.dart';
import '../../../model/supplier_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../utils/date_formator.dart';
import '../../../utils/debouncer.dart';
import '../../../widgets/app_snackbars.dart';
import '../../../widgets/global_textfield.dart';
import '../../../widgets/search_dropdown_with_pagination.dart';

class CreatePoScreen extends StatelessWidget {
  CreatePoScreen({super.key, this.poID});
  final int? poID;
  final productController = Get.find<ProductController>();
  final supplierController = Get.find<SupplierController>();
  final poController = Get.find<PurchaseOrderController>();
  final _dbouncer = Debouncer(delay: const Duration(milliseconds: 500));
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('${poID == null ? 'Create' : 'Edit'} Purchase Order'),
      ),

      body: SingleChildScrollView(
        child: Obx(
          () => Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  /// -----------------------------
                  /// Supplier Selection
                  /// -----------------------------
                  GlobalTextFormField(
                    readOnly: true,
                    controller: poController.supplierNameController,
                    onTap: () => _openSupplierSelector(),
                    label: 'Select Supplier',
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'supplier is required'
                        : null,
                  ),

                  /// -----------------------------
                  /// Product Selection
                  /// -----------------------------
                  GlobalTextFormField(
                    readOnly: true,
                    controller: poController.itemNameController,
                    onTap: () => _openProductSelector(),
                    label: 'Select Product',
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'product is required'
                        : null,
                  ),

                  /// -----------------------------
                  /// Cost & Quantity Fields
                  /// -----------------------------
                  GlobalTextFormField(
                    label: "Cost price",
                    controller: poController.itemCostPriceController,
                    textInputType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "this field is required";
                      } else if (double.parse(value) <= 0) {
                        return 'price must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  GlobalTextFormField(
                    label: "Stock qty",
                    controller: poController.itemQuantityController,
                    textInputType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "this field is required";
                      } else if (int.parse(value) <= 0) {
                        return 'stock must be greater than 0';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  /// -----------------------------
                  /// Add Product Button
                  /// -----------------------------
                  GlobalAppSubmitBtn(
                    title: 'Add product',
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        poController.addToList();
                      } else {
                        AppSnackbars.error('Failed', 'Failed to add product');
                      }
                    },
                  ),

                  const SizedBox(height: 10),

                  /// -----------------------------
                  /// Supplier Label
                  /// -----------------------------
                  _buildSupplierLabel(),

                  /// -----------------------------
                  /// Product Table Header
                  /// -----------------------------
                  _buildTableHeader(),

                  /// -----------------------------
                  /// Product List
                  /// -----------------------------
                  _buildProductList(),

                  /// -----------------------------
                  /// Summary Row
                  /// -----------------------------
                  _buildSummary(),

                  const SizedBox(height: 16),

                  /// -----------------------------
                  /// Create Order Button
                  /// -----------------------------
                  Visibility(
                    visible: poController.items.isNotEmpty,
                    child: GlobalAppSubmitBtn(
                      title: '${poID == null ? 'Create' : 'Save'} order',
                      onTap: () {
                        poController.addOREditPO(poID: poID);
                      },
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // BottomSheet: Supplier Selection
  // ----------------------------------------------------------
  void _openSupplierSelector() {
    Get.bottomSheet(
      CustomSearchDropdown<SupplierModel>(
        title: 'Suppliers',
        isLoading: supplierController.isLoading,
        itemLabel: (supplier) => supplier.supplierName,
        onItemSelected: (supplier) {
          poController.supplierID = supplier.supplierId;
          poController.supplierNameController.text = supplier.supplierName;
          poController.supplierName.value = supplier.supplierName;
        },
        searchController: supplierController.dropdownSearchController,
        pagingController: supplierController.pagingController,
        onSearch: (val) =>
            _dbouncer.run(() => supplierController.updateSearchQuery(val)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
    );
  }

  // ----------------------------------------------------------
  // BottomSheet: Product Selection
  // ----------------------------------------------------------
  void _openProductSelector() {
    Get.bottomSheet(
      CustomSearchDropdown<ProductModel>(
        title: 'Products',
        isLoading: productController.isLoading,
        itemLabel: (product) => product.productName,
        onItemSelected: (product) {
          poController.itemID = product.productId;
          poController.itemNameController.text = product.productName;
        },
        searchController: productController.dropdownSearchController,
        pagingController: productController.pagingController,
        onSearch: (val) =>
            _dbouncer.run(() => productController.updateSearchQuery(val)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
    );
  }

  Widget _buildSupplierLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        children: [
          // Supplier Name Section
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Supplier : ",
                    style: AppTextStyle.semiBoldTextstyle.copyWith(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: poController.supplierName.isEmpty
                        ? "Not selected"
                        : poController.supplierName.value,
                    style: AppTextStyle.regularTextstyle.copyWith(
                      fontSize: 14,
                      color: poController.supplierName.isEmpty
                          ? Colors.grey
                          : primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Date Section + Calendar Icon
          InkWell(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: Get.context!,
                initialDate: poController.selectedDate.value ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                poController.selectedDate.value = pickedDate;
              }
            },
            child: Row(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Date : ",
                        style: AppTextStyle.semiBoldTextstyle.copyWith(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: poController.selectedDate.value == null
                            ? "dd / mm / yyyy"
                            : DateFormator.formateDate(poController.selectedDate.value!),
                        style: AppTextStyle.regularTextstyle.copyWith(
                          fontSize: 14,
                          color: poController.selectedDate.value == null
                              ? Colors.grey
                              : primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // Table Header
  // ----------------------------------------------------------
  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          _headerCell('Item Name', flex: 2),
          _headerCell('Qty'),
          _headerCell('Price'),
          _headerCell('Total'),
          _headerCell('Remove'),
        ],
      ),
    );
  }

  Widget _headerCell(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 12),
      ),
    );
  }

  // ----------------------------------------------------------
  // Product List
  // ----------------------------------------------------------
  Widget _buildProductList() {
    if (poController.items.isEmpty) {
      return const Center(child: Text('Feeling too light'));
    }

    return ListView.builder(
      itemCount: poController.items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = poController.items[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          elevation: 0,
          color: bg,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dataCell(item.itemName ?? 'undefined', flex: 2),
                _dataCell(item.quantity.toString()),
                _dataCell(item.costPerUnit.toString()),
                _dataCell((item.quantity * item.costPerUnit).toString()),
                Expanded(
                  child: GestureDetector(
                    onTap: () => poController.removeItem(index),
                    child: Icon(Icons.delete_outline, color: primary),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dataCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyle.regularTextstyle.copyWith(fontSize: 12),
      ),
    );
  }

  // ----------------------------------------------------------
  // Summary Section
  // ----------------------------------------------------------
  Widget _buildSummary() {
    return Visibility(
      visible: poController.items.isNotEmpty,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryCell('Total'),
            _summaryCell('Qty = ${poController.totalQuantity.value}'),
            _summaryCell(
              'Amount = ${poController.totalCost.value.toStringAsFixed(0)}',
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 12),
      ),
    );
  }
}
