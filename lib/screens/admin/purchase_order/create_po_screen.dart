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
                  /// Header Section: Supplier, Date, Order Info
                  _buildHeaderSection(),

                  const SizedBox(height: 24),

                  /// Product Selection & Details Section
                  _buildProductDetailsSection(),



                  const SizedBox(height: 24),


                  GlobalAppSubmitBtn(
                    title: '${poID == null ? 'Create' : 'Save'} order',
                    onTap: () {
                      poController.addOREditPO(poID: poID);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Header Section with Supplier & Date at top
  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Information',
            style: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 12),

          /// Supplier Selection
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
          const SizedBox(height: 12),

          /// Date Picker
          GestureDetector(
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Date',
                        style: AppTextStyle.regularTextstyle
                            .copyWith(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        poController.selectedDate.value == null
                            ? 'dd / mm / yyyy'
                            : DateFormator.formateDate(poController.selectedDate.value!),
                        style: AppTextStyle.semiBoldTextstyle.copyWith(
                          fontSize: 14,
                          color: poController.selectedDate.value == null
                              ? Colors.grey
                              : primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Product Details Section
  Widget _buildProductDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Details',
            style: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 12),

          /// Product Selection
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
          const SizedBox(height: 12),

          /// Cost & Quantity in Row
          Row(
            children: [
              Expanded(
                child: GlobalTextFormField(
                  label: "Cost Price",
                  controller: poController.itemCostPriceController,
                  textInputType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "required";
                    } else if (double.parse(value) <= 0) {
                      return 'must be > 0';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlobalTextFormField(
                  label: "Stock Qty",
                  controller: poController.itemQuantityController,
                  textInputType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "required";
                    } else if (int.parse(value) <= 0) {
                      return 'must be > 0';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
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
          poController.productID = product.productId;
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


}