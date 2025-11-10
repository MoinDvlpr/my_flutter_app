import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_flutter_app/screens/admin/purchase_order/purchase_orders_screen.dart';
import '../controllers/auth_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/discount_group_controller.dart';
import '../controllers/inventory_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/purchase_order_controller.dart';
import '../controllers/supplier_controller.dart';
import '../controllers/user_controller.dart';
import '../screens/admin/category/categories.dart';
import '../screens/admin/dashboard_screen.dart';
import '../screens/admin/discountgroup/assign_discount_group.dart';
import '../screens/admin/discountgroup/discount_groups_screen.dart';
import '../screens/admin/inventory/inventory_screen.dart';
import '../screens/admin/new arrivals/receive_po_screen.dart';
import '../screens/admin/order/all_orders_screen.dart';
import '../screens/admin/product/products.dart';
import '../screens/admin/supplier/suppliers.dart';
import '../screens/admin/user/users_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_textstyles.dart';
import 'confirm_dialog.dart';

class AdminDrawer extends StatelessWidget {
  AdminDrawer({super.key});
  final authController = Get.find<AuthController>();
  final userController = Get.put(UserController());
  final poController = Get.put(PurchaseOrderController());
  final dashboardController = Get.put(DashboardController());
  final categoryController = Get.put(CategoryController());
  final productController = Get.put(ProductController());
  final supplierController = Get.put(SupplierController());
  final inventoryController = Get.put(InventoryController());
  final discountGroupController = Get.put(DiscountGroupController());

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(12.0),
          bottomRight: Radius.circular(12.0),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              onTap: () async {
                Get.offAll(() => AdminDashboard());
                await dashboardController.fetchDashboardData();
                await dashboardController.fetchMostSellingProducts(
                  isInitial: true,
                );
              },
              leading: Icon(Icons.home),
              title: Text('Home', style: AppTextStyle.lableStyle),
            ),

            ListTile(
              onTap: () async {
                Get.to(() => ReceivePOsScreen());
              },
              leading: Icon(Icons.fire_truck_outlined),
              title: Text('New arrivals', style: AppTextStyle.lableStyle),
            ),
            ListTile(
              onTap: () async {
                Get.to(() => PurchaseOrdersScreen());
              },
              leading: Icon(Icons.inventory_2_outlined),
              title: Text('POs', style: AppTextStyle.lableStyle),
            ),
            ListTile(
              onTap: () async {
                supplierController.searchQuery = "";
                Get.to(() => SuppliersScreen());
                // await userController.fetchAllUsers(isInitial: true);
              },
              leading: Icon(Icons.people),
              title: Text('Suppliers', style: AppTextStyle.lableStyle),
            ),
            ListTile(
              onTap: () async {
                userController.searchQuery = "";
                Get.to(() => UsersScreen());
                // await userController.fetchAllUsers(isInitial: true);
              },
              leading: Icon(Icons.group),
              title: Text('Customers', style: AppTextStyle.lableStyle),
            ),
            ListTile(
              onTap: () async {
                discountGroupController.searchQuery = "";
                Get.to(() => DiscountGroupsScreen());
                // await discountGroupController.fetchAllGroups(isInitial: true);
              },
              leading: Icon(Icons.groups),
              title: Text('Discount Groups', style: AppTextStyle.lableStyle),
            ),
            ListTile(
              onTap: () async {
                discountGroupController.clearAssignControllers();
                Get.to(() => AssignDiscountGroup());
              },
              leading: Icon(Icons.group_work_outlined),
              title: Text(
                'Assign Discount Groups',
                style: AppTextStyle.lableStyle,
              ),
            ),
            ListTile(
              onTap: () async {
                categoryController.searchQuery = "";
                Get.to(() => Categories());
                await categoryController.fetchAllCategories(isInitial: true);
              },
              leading: Icon(Icons.category),
              title: Text('Categories', style: AppTextStyle.lableStyle),
            ),
            ListTile(
              onTap: () async {
                Get.to(() => InventoryScreen());
              },
              leading: Icon(Icons.storefront_sharp),
              title: Text('Inventory', style: AppTextStyle.lableStyle),
            ),
            ListTile(
              onTap: () async {
                productController.reset();
                Get.to(() => ProductsScreen());
              },
              leading: Icon(Icons.shopping_bag_outlined),
              title: Text('Products', style: AppTextStyle.lableStyle),
            ),
            ListTile(
              onTap: () {
                Get.to(() => AllOrdersScreen());
              },
              leading: Icon(Icons.sticky_note_2_outlined),
              title: Text('Orders', style: AppTextStyle.lableStyle),
            ),
            ListTile(
              onTap: () {
                showDeleteConfirmationDialog(
                  confirmLabel: 'Logout',
                  title: 'Logout',
                  message: 'Are you sure ?',
                  onConfirm: () async {
                    await authController.logout();
                  },
                );
              },
              leading: Icon(Icons.logout),
              title: Text('Logout', style: AppTextStyle.lableStyle),
            ),
          ],
        ),
      ),
    );
  }
}
