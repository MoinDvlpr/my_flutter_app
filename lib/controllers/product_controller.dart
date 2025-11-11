import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:path_provider/path_provider.dart';
import '../dbservice/db_helper.dart';
import '../model/product_model.dart';
import '../utils/app_constant.dart';
import '../utils/dialog_utils.dart';
import '../widgets/app_snackbars.dart';
import 'dashboard_controller.dart';
import 'package:path/path.dart' as p;

class ProductController extends GetxController {
  // dropdown search controller
  TextEditingController dropdownSearchController = TextEditingController();
  // PagingController for infinite scroll
  final PagingController<int, ProductModel> pagingController =
      PagingController<int, ProductModel>(
        // Start with page 1
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => fetchProducts(page: pageKey),
      );

  // PagingController for infinite scroll
  final PagingController<int, ProductModel> pagingControllerForCatWiseProducts =
      PagingController<int, ProductModel>(
        // Start with page 1
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => fetchAllProductsByCatId(page: pageKey),
      );

  // PagingController for infinite scroll
  final PagingController<int, ProductModel> pagingControllerForFavs =
      PagingController<int, ProductModel>(
        // Start with page 1
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => fetchAllFavorites(page: pageKey),
      );
  @override
  void onInit() {
    pagingController.refresh();
    super.onInit();
  }

  RxBool isLoading = false.obs;
  RxList<ProductModel> products = <ProductModel>[].obs;

  /////// Add/Edit Product ////////
  // text editing controller
  TextEditingController productNameController = TextEditingController();
  TextEditingController productDescController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController productCostPriceController = TextEditingController();
  TextEditingController productStockController = TextEditingController();
  TextEditingController categoryNameController = TextEditingController();
  TextEditingController marketPriceController = TextEditingController();
  RxString productImage = "".obs;
  int soldQty = 0;
  RxInt? _categoryID;
  String insertDate = "";
  set setCategoryID(int value) {
    _categoryID = value.obs;
  }

  // get download dir
  Future<String> getPublicDownloadDirPath() async {
    if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } else {
      // For Android, use the public Downloads folder
      final Directory targetDir = Directory('/storage/emulated/0/Download/');

      if (!(await targetDir.exists())) {
        await targetDir.create(recursive: true);
      }
      return targetDir.path;
    }
  }

  final categorySearchController = TextEditingController();
  RxInt? get categoryID => _categoryID;
  var selectedImages = <File>[].obs;
  String imagePaths = "";

  Future<void> pickMultipleImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      final appDir = await getPublicDownloadDirPath();
      final List<File> copiedFiles = [];

      for (final filePath in result.paths) {
        if (filePath != null) {
          // final originalFile = File(filePath);
          final newFilePath = p.join(appDir, p.basename(filePath));
          // final copiedFile = await originalFile.copy(newFilePath);
          copiedFiles.add(File(newFilePath));
        }
      }

      selectedImages.addAll(copiedFiles);
      imagePaths = copiedFiles
          .map((file) => file.path)
          .join(','); // comma-separated for DB
    }
  }

  ProductModel? product;
  // Fetch single product for edit
  Future<void> fetchProductByID({required int productID}) async {
    try {
      isLoading.value = true;
      var result = await DatabaseHelper.instance.getProductByID(
        productID: productID,
      );
      if (result != null && result.isNotEmpty) {
        product = ProductModel.fromMap(result);
        if (product?.productImage != null && product!.productImage.isNotEmpty) {
          List<String> imagePaths = product!.productImage.split(",");
          selectedImages.addAll(imagePaths.map((p) => File(p)).toList());
        }
        productNameController.text = product!.productName;
        productPriceController.text = product!.price.toString();
        marketPriceController.text = product!.marketPrice.toString();
        productCostPriceController.text = product!.costPrice.toString();
        productStockController.text = product!.stockQty.toString();
        productDescController.text = product!.description ?? '';
        setCategoryID = product!.categoryId;
        insertDate = product!.insertDate;
        soldQty = product!.soldQty;
      } else {
        Get.closeAllSnackbars();
        AppSnackbars.error('Failed!', "Failed to fetch product!");
      }
    } catch (e) {
      Get.closeAllSnackbars();
      AppSnackbars.error('Error!', "Something went wrong!");
      log("error (fetchProductByID) : : : -->> ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  final dashboardController = Get.put(DashboardController());
  // addOrEditProduct
  Future<void> addOrEditProduct({int? productID}) async {
    try {
      isLoading.value = true;
      if (productID == null) {
        if (selectedImages.isNotEmpty) {
          imagePaths = selectedImages.map((e) => e.path).join(',');
          if (categoryID != null && (productStockController.text.isNotEmpty)) {
            ProductModel product = ProductModel(
              productName: productNameController.text.trim(),
              description: productDescController.text.trim(),
              price: double.parse(productPriceController.text.trim()),
              costPrice: double.parse(productCostPriceController.text.trim()),
              marketPrice: double.parse(marketPriceController.text.trim()),
              stockQty: int.parse(productStockController.text.trim()),
              categoryId: categoryID!.value,
              productImage: imagePaths,
              soldQty: 0,
              insertDate: DateTime.now().toString(),
            );
            var result = await DatabaseHelper.instance.insertProduct(
              product: product,
            );
            if (result != null && result != 0) {
              clearControllers();
              Get.back();
              Get.closeAllSnackbars();
              AppSnackbars.success('Success!', "Product added successfully!");
              pagingController.refresh();

              await dashboardController.fetchDashboardData();
            } else if (result == null) {
              Get.closeAllSnackbars();
              AppSnackbars.error('Failed', "Failed to add product");
            }
          }
        } else {
          Get.closeAllSnackbars();
          AppSnackbars.error('Image is missing!', 'image is required');
        }
      } else {
        if (_categoryID != null) {
          if (selectedImages.isNotEmpty) {
            imagePaths = selectedImages.map((e) => e.path).join(',');
          } else {
            imagePaths = "";
          }
          ProductModel product = ProductModel(
            productId: productID,
            marketPrice: double.parse(marketPriceController.text.trim()),
            description: productDescController.text.trim(),
            productName: productNameController.text.trim(),
            price: double.parse(productPriceController.text.trim()),
            costPrice: double.parse(productCostPriceController.text.trim()),
            stockQty: int.parse(
              productStockController.text.isEmpty
                  ? "0"
                  : productStockController.text.trim(),
            ),
            categoryId: categoryID!.value,
            productImage: imagePaths,
            soldQty: soldQty,
            insertDate: insertDate,
          );
          var result = await DatabaseHelper.instance.updateProduct(
            product: product,
          );
          if (result != null && result != 0) {
            clearControllers();
            Get.back();
            Get.closeAllSnackbars();
            AppSnackbars.success('Success!', "Product updated successfully!");
            pagingController.refresh();
          } else if (result == null) {
            Get.closeAllSnackbars();
            AppSnackbars.error('Failed', "Failed to update product");
          }
        }
      }
    } catch (e) {
      Get.closeAllSnackbars();
      AppSnackbars.error("Error!", "Something went wrong!");
      log("error : : : : (addOrEditProduct) ==>> ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // delete  product
  Future<void> deleteProduct({required int id, required int index}) async {
    try {
      var result = await DatabaseHelper.instance.deleteProduct(productID: id);
      if (result != null && result != 0) {
        clearControllers();
        Get.back();

        DialogUtils.showSuccessDialog(
          title: 'Success',
          message: 'Product deleted successfully!',
        );
        log("Product deleted successfully!");
        pagingController.refresh();
        await dashboardController.fetchDashboardData();
      } else {
        Get.back();
        DialogUtils.showErrorDialog(
          title: 'Failed',
          message: 'Failed to delete product!',
        );
        log("failed to delete product!");
      }
    } catch (e) {
      Get.back();
      DialogUtils.showErrorDialog(
        title: 'Error!',
        message: 'Something went wrong!',
      );
      log("error (deleteProduct (controller)) : : :  -- > ${e.toString()}");
    }
  }

  ////////// user side ////////
  int currentPage = 0;
  int pageSize = 10;
  int totalPages = 0;
  String searchQuery = "";
  int filterCatId = 0;
  String sortType = 'most_popular';

  ////////  with pagination and all things
  static Future<List<ProductModel>> fetchProducts({required int page}) async {
    try {
      final controller = Get.find<ProductController>();
      controller.isLoading.value = true;

      // Resolve dynamic filters
      String? query = controller.searchQuery.trim().isNotEmpty
          ? controller.searchQuery
          : null;
      int? category = controller.filterCatId > 0
          ? controller.filterCatId
          : null;
      // Fetch paginated data
      final newProducts = await DatabaseHelper.instance.getFilteredProducts(
        userId: controller.storage.read(USERID),
        searchQuery: query,
        categoryId: category,
        sortType: controller.sortType,
        limit: controller.pageSize,
        offset: (page - 1) * controller.pageSize,
      );
      return newProducts;
    } catch (e) {
      log("error (fetchProducts): ${e.toString()}");
      return [];
    } finally {
      Get.find<ProductController>().isLoading.value = false;
    }
  }

  // Update search query and refresh the list
  void updateSearchQuery(String query) {
    searchQuery = query;
    pagingController.refresh(); // Refresh the list when search changes
  }

  GetStorage storage = GetStorage();

  ////////// filter chips ///////////////
  // fetch filtered products
  int catID = 0;
  int currentCatPage = 0;
  int catPageSize = 10;
  int totalCatPages = 0;
  RxBool isCatLoading = false.obs;
  RxList<ProductModel> categoryWiseProducts = <ProductModel>[].obs;
  static Future<List<ProductModel>> fetchAllProductsByCatId({
    required int page,
  }) async {
    try {
      final productController = Get.find<ProductController>();
      productController.isCatLoading.value = true;
      final newCatWiseProds = await DatabaseHelper.instance.getFilteredProducts(
        categoryId: productController.catID,
        userId: productController.storage.read(USERID),
        limit: productController.catPageSize,
        offset: (page - 1) * productController.catPageSize,
      );

      return newCatWiseProds;
    } catch (e) {
      log("error (fetchAllProductsByCatId) : : :  -- > ${e.toString()}");
      return [];
    } finally {
      Get.find<ProductController>().isCatLoading.value = false;
    }
  }

  // handle filter chips
  RxMap<int, bool> selected = <int, bool>{}.obs;
  RxMap<int, bool> chipSelected = <int, bool>{}.obs;
  void onChipSelected(int catID, int index, bool value) async {
    chipSelected.updateAll((key, value) => false);
    chipSelected[index] = value;
    final anySelected = chipSelected.values.any((element) => element == true);
    if (!anySelected) {
      filterCatId = 0;
      pagingController.refresh();
    } else {
      filterCatId = catID;
      pagingController.refresh();
    }
  }

  // search products
  Future<void> search(String query) async {
    filterCatId = 0;
    sortType = "most_popular";
    searchQuery = query;
    selected.updateAll((key, value) => false);
    chipSelected.updateAll((key, value) => false);
    pagingController.refresh();
  }

  // add to favorite
  RxMap<int, bool> isFavoriteProduct = <int, bool>{}.obs;
  Future<void> addToFavorite(int productID, {int? index}) async {
    try {
      var result = await DatabaseHelper.instance.insertFavorite(
        productID: productID,
        userID: storage.read(USERID),
      );

      if (result != null && result != 0) {
        isFavoriteProduct[productID] = true;
        if (index != null) {
          ProductModel favProduct = products.firstWhere(
            (product) => product.productId == productID,
          );
          allFavorites.insert(0, favProduct);
        }
      } else {
        log("failed to add favorite!");
      }
    } catch (e) {
      log("error (addToFavorite) : : : ${e.toString()}");
    }
  }

  // remove from favorite
  Future<void> removeFavorite(int productID, {int? index}) async {
    try {
      var result = await DatabaseHelper.instance.removeFromFavorites(
        productID,
        storage.read(USERID),
      );
      if (result != null && result != 0) {
        isFavoriteProduct[productID] = false;
        if (index != null) {
          pagingControllerForFavs.refresh();
        }
      } else {
        log("failed to remove favorite!");
      }
    } catch (e) {
      log("error (removeFavorite) : : : ${e.toString()}");
    }
  }

  // product detail screen
  // detail vars
  RxInt stockQty = 0.obs;
  RxString productName = "".obs;
  RxString productDesc = "".obs;
  RxBool isFavorite = false.obs;
  RxDouble discountPercentage = 0.0.obs;
  RxDouble price = 0.0.obs;
  RxDouble discountedPrice = 0.0.obs;
  Future<void> fetchProductDetails(int productID) async {
    try {
      isLoading.value = true;
      var result = await DatabaseHelper.instance.getProductByIDForDetail(
        productID,
        storage.read(USERID),
      );
      if (result != null) {
        stockQty.value = result.stockQty;
        productImage.value = result.productImage;
        productName.value = result.productName;
        productDesc.value = result.description ?? '';
        isFavorite.value = result.isFavorite;
        discountPercentage.value = result.discountPercentage ?? 0.0;
        price.value = result.price;
        discountedPrice.value = result.discountedPrice ?? 0.0;
      } else {
        log("failed to load product details.");
      }
    } catch (e) {
      log("error (fetchProductDetails) : : : : ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // filter from bottom sheet
  RxInt selectedSortIndex = 0.obs;
  final sortOptions = [
    'Most Popular',
    'Price: lowest to high',
    'Price: highest to low',
    'A-Z',
    'Z-A',
  ];

  // on filter select from bottom sheet
  onFilterSelected(int index) async {
    selectedSortIndex.value = index;
    selected.updateAll((key, value) => false);
    Get.back();
    if (index == 0) {
      sortType = 'most_popular';
      pagingController.refresh();
      ;
    } else if (index == 1) {
      sortType = "price_low_to_high";
      pagingController.refresh();
    } else if (index == 2) {
      sortType = "price_high_to_low";

      pagingController.refresh();
    } else if (index == 3) {
      sortType = "name_asc";
      pagingController.refresh();
    } else if (index == 4) {
      sortType = "name_desc";
      pagingController.refresh();
    } else {
      sortType = 'most_popular';
      pagingController.refresh();
    }
  }

  // description is expand or not
  RxBool isExpanded = false.obs;
  onExpanded() {
    isExpanded.value = !isExpanded.value;
  }

  // add to cart
  Future<void> addToCart({required int productID, int quantity = 1}) async {
    try {
      var result = await DatabaseHelper.instance.insertIntoCart(
        storage.read(USERID),
        productID,
        quantity,
      );
      if (result != null && result != 0) {
        Get.closeAllSnackbars();
        AppSnackbars.success('Success!', "Add to cart successfully!");
      } else {
        Get.closeAllSnackbars();
        AppSnackbars.error('Failed', 'Failed to add product in cart');
      }
    } catch (e) {
      Get.closeAllSnackbars();
      AppSnackbars.error('Oops!', "Something went wrong!");
      log("error >> (addToCart) : : : : : --> ${e.toString()}");
    }
  }

  // fetch all favorites
  RxBool isFavLoading = false.obs;
  int currentFavPage = 0;
  int favPageSize = 10;
  int totalFavPages = 0;
  RxList<ProductModel> allFavorites = <ProductModel>[].obs;
  static Future<List<ProductModel>> fetchAllFavorites({
    required int page,
  }) async {
    try {
      final controller = Get.find<ProductController>();
      controller.isFavLoading.value = true;
      final newFavorites = await DatabaseHelper.instance.getAllFavoriteProducts(
        controller.storage.read(USERID),
        limit: controller.favPageSize,
        offset: (page - 1) * controller.favPageSize,
      );
      return newFavorites;
    } catch (e) {
      log("error (fetchAllFavorites) : : : : -->> ${e.toString()}");
      return [];
    } finally {
      Get.find<ProductController>().isFavLoading.value = false;
    }
  }

  // reset sorting, filter and search
  void reset() {
    searchQuery = "";
    sortType = "most_popular";
    selected.updateAll((key, value) => false);
    chipSelected.updateAll((key, value) => false);
    onFilterSelected(0);
  }

  // clear controller
  void clearControllers() {
    marketPriceController.clear();
    categoryNameController.clear();
    productNameController.clear();
    productPriceController.clear();
    productCostPriceController.clear();
    productDescController.clear();
    productStockController.clear();
    productPriceController.clear();
    _categoryID = null;
    selectedImages.clear();
  }

  setCatIDNull() {
    _categoryID = null;
  }
}
