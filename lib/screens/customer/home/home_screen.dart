import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../controllers/ai_controller.dart';
import '../../../controllers/category_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../utils/app_colors.dart';
import '../buym8/chat_screen.dart';
import '../category/user_categories_screen.dart';
import '../product/my_favorites_screen.dart';
import '../product/user_products_screen.dart';
import '../profile/user_profile_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final PersistentTabController _controller = PersistentTabController(
    initialIndex: 0,
  );
  final productController = Get.put(ProductController());
  final aiController = Get.put(AIController());
  final categoryController = Get.put(CategoryController());
  final GetStorage storage = GetStorage();
  List<Widget> _screens() {
    return [
      UserProductsScreen(),
      UserCategoryScreen(),
      FavoritesScreen(),
      UserProfileScreen(),
      AIChatScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home_outlined),
        title: "Home",
        activeColorPrimary: primary,
        inactiveColorPrimary: grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.shopping_bag_outlined),
        title: "Category",
        activeColorPrimary: primary,
        inactiveColorPrimary: grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.favorite_outline),
        title: "Favorite",
        activeColorPrimary: primary,
        inactiveColorPrimary: grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person_outline_rounded),
        title: "Profile",
        activeColorPrimary: primary,
        inactiveColorPrimary: grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.bubble_chart_sharp),
        title: "BuyM8",
        activeColorPrimary: primary,
        inactiveColorPrimary: grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _screens(),
      items: _navBarItems(),
      hideNavigationBarWhenKeyboardAppears: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      backgroundColor: bg,
      isVisible: true,
      confineToSafeArea: true,
      navBarHeight: kBottomNavigationBarHeight,
      navBarStyle: NavBarStyle.style6,
      onItemSelected: (value) async {
        if (value == 2) {
          productController.pagingControllerForFavs.refresh();
        }
        if (value == 1) {
          categoryController.pagingController.refresh();
        }
      },
    );
  }
}
