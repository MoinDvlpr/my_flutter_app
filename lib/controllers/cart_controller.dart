import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_flutter_app/model/order_item_model.dart';
import 'package:my_flutter_app/utils/app_constant.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import '../dbservice/db_helper.dart';
import '../model/cart_model.dart';
import '../model/order_model.dart';
import '../screens/customer/myorders/order_success_screen.dart';
import '../widgets/app_snackbars.dart';
import 'auth_controller.dart';

class CartController extends GetxController {
  @override
  void onInit() {
    fetchAllCartItems();
    super.onInit();
    _initRazorpayListeners();
  }

  void _initRazorpayListeners() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  RxBool isLoading = false.obs;
  RxBool isPaymentLoading = false.obs;

  final authController = Get.put(AuthController());

  // for get user from local storage
  GetStorage storage = GetStorage();
  // cart total
  RxDouble subTotal = 0.0.obs;
  RxDouble deliveryCharge = 150.0.obs;
  RxDouble total = 0.0.obs;
  int totalQty = 0;

  // fetch all cart items
  RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  Future<void> fetchAllCartItems() async {
    try {
      isLoading.value = true;
      totalQty = 0;
      var result = await DatabaseHelper.instance
          .getCartItemsWithDiscountByUserID(storage.read(USERID));
      cartItems.value = result;
      subTotal.value = 0.0;
      for (var item in cartItems) {
        cartItemQty[item.productId] = item.qty;
        totalQty += item.qty;
        subTotal.value += item.totalPrice;
      }
      total.value = subTotal.value + deliveryCharge.value;
    } catch (e) {
      log("error (fetchAllCartItems) : : : : ==> ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // delete from cart
  Future<void> deleteFromCart(int cartID) async {
    try {
      var result = await DatabaseHelper.instance.deleteFromCart(cartID);
      if (result != null && result != 0) {
        await fetchAllCartItems();
      }
    } catch (e) {
      log("error (deleteFromCart): : : ${e.toString()}");
    }
  }

  final cartItemQty = <int, int>{}.obs;
  // decrease qty
  Future<void> decreaseQty(
    int cartID,
    int qty,
    int productId,
    double price,
  ) async {
    try {
      if (qty > 1) {
        var result = await DatabaseHelper.instance.decreaseQuantity(
          cartID,
          qty - 1,
        );
        if (result != null && result != 0) {
          if (qty > 1) {
            if (cartItemQty[productId] != null) {
              cartItemQty[productId] = qty - 1;
              subTotal.value -= price;
              total.value -= price;
            }
            log("decrease successfully");
          }
        } else {
          log("failed to decrease quantity");
        }
      }
    } catch (e) {
      log("error (decreaseQty) : : :: ${e.toString()}");
    }
  }

  // increase qty

  Future<void> increaseQty({
    required int productID,
    int quantity = 1,
    required double price,
  }) async {
    try {
      var result = await DatabaseHelper.instance.insertIntoCart(
        storage.read(USERID),
        productID,
        quantity,
      );
      if (result != 0) {
        cartItemQty[productID] = (cartItemQty[productID] ?? 0) + quantity;
        subTotal.value += price;
        total.value += price;
        log("quantity increase successfully!");
      } else {
        log('Failed to add product in cart');
      }
    } catch (e) {
      log("error >> (increaseQty) : : : : : --> ${e.toString()}");
    }
  }

  // check stock
  Future<bool> checkStock() async {
    bool isAvailable = false;
    for (var item in cartItems) {
      final stock = await DatabaseHelper.instance.fetchStock(item.productId);
      if (!(stock[STOCK_QTY] >= cartItemQty[item.productId])) {
        isAvailable = false;
        break;
      } else {
        isAvailable = true;
      }
    }
    return isAvailable;
  }

  late Razorpay _razorpay;
  String key_id = 'rzp_test_yrrzTp3Xulx2Aq';
  String key_secret = 'tYjzJOizbvLJBqvshqnpZpp9';

  // STEP 1: Called when user taps "Checkout"
  Future<void> createOrderFromCart() async {
    try {
      isPaymentLoading.value = true;
      _initRazorpayListeners();

      // Create Razorpay order
      String razorpayOrderId = await createRazorpayOrder(total.value);
      if (razorpayOrderId.isNotEmpty) {
        log("order id from razor pay : : : : $razorpayOrderId");
        // Open Razorpay UI
        openCheckout(razorpayOrderId, total.value, totalQty, {
          'name': authController.fullName.trim(),
          'address': authController.address.trim(),
          'city': authController.cityName.trim(),
          'state': authController.stateName.trim(),
          'zip': authController.zipcode.trim(),
          'country': authController.countryName.trim(),
        });
      }
    } catch (e) {
      log(
        "Error in createOrderFromCart: : : : : : : : : : : ::: :: : :: :  ::${e.toString()}",
      );
    }
  }

  // Create Razorpay order
  Future<String> createRazorpayOrder(double totalAmount) async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$key_id:$key_secret'))}';
    final response = await http.post(
      Uri.parse("https://api.razorpay.com/v1/orders"),
      headers: {'Content-Type': 'application/json', 'Authorization': basicAuth},

      body: jsonEncode({
        'amount': (totalAmount * 100).toInt(),
        'currency': 'INR',
        'receipt': 'receipt_${DateTime.now().millisecondsSinceEpoch}',
      }),
    );
    log(
      ": : : :: : : : : : : : : : :response from create order  : : : : : : : : : : ${response.body}",
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log(
        ": : : : : : : : : : : : : : : :  : : : : : : : : :  : :data from create order ::: ${response.body}",
      );
      return data['id'];
    } else {
      log("Failed to create Razorpay order");
      return "";
    }
  }

  // STEP 3: Open Razorpay UI
  void openCheckout(
    String razorpayOrderId,
    double totalAmount,
    int totalQty,
    Map<String, dynamic> fullAddress,
  ) {
    var options = {
      'key': key_id,
      'amount': (totalAmount * 100).toInt(),
      'name': 'My Store',
      'description': "Qty: $totalQty",
      'order_id': razorpayOrderId,
      'prefill': {
        'contact': storage.read(CONTACT),
        'email': storage.read(EMAIL),
      },
      'notes': fullAddress,
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      Get.closeAllSnackbars();
      AppSnackbars.error('Error', e.toString());
    }
  }

  /// STEP 4 payment success
  // Updated _handlePaymentSuccess function
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    log(
      "Payment Success: : : : : : : : : : : : : : : : : :${response.paymentId}",
    );
    log(response.data.toString());
    log(response.toString());
    try {
      if (response.paymentId != null) {
        String paymentMethod = await fetchPaymentMethod(
          response.paymentId ?? '',
        );
        final fullAddress =
            "${authController.fullName.trim()}, ${authController.address.trim()}, ${authController.cityName.trim()}, ${authController.stateName.trim()}, ${authController.zipcode.trim()}";
        // INSERT ORDER IN DB
        final order = OrderModel(
          orderStatus: 'Paid',
          userId: storage.read(USERID),
          razorpaySignature: response.signature ?? '',
          orderDate: DateTime.now().toString(),
          razorpayOrderId: response.orderId ?? '',
          razorpayPaymentId: response.paymentId ?? '',
          shippingAddress: fullAddress,
          customerName: storage.read(USERNAME),
          paymentMethod: paymentMethod,
          totalAmount: total.value,
          totalQuantity: totalQty,
          latitude: authController.lati,
          longitude: authController.longi,
        );
        final int? orderID = await DatabaseHelper.instance.insertOrder(order);
        if (orderID != null) {
          // Insert order items and deduct stock for each cart item
          for (var item in cartItems) {
            int qty =
                cartItemQty[item.productId] ??
                1; // Assuming CartItemModel has a 'qty' field; adjust if using cartItemQty map
            // Deduct stock and get list of serial numbers
            List<String> serialNumbersList = await DatabaseHelper.instance
                .deductStock(productID: item.productId, qty: qty);

            // INSERT ORDER ITEM
            final orderItem = OrderItemModel(
              productID: item.productId,
              orderId: orderID,
              itemName:
                  item.productName, // Assuming CartItemModel has 'productName'
              serialNumbers: serialNumbersList,
              itemQty: qty,
              itemImage: item
                  .productImage, // Assuming CartItemModel has 'productImage'

              itemPrice: item.discountedPrice,
              discountPercentage:
                  item.discountPercentage ??
                  0.0, // Assuming CartItemModel has 'discountPercentage'; default to 0.0
            );
            await DatabaseHelper.instance.insertOrderItem(orderItem);
          }
          AppSnackbars.success('Success', 'Payment completed and order placed');
          Get.off(() => OrderSuccessScreen());
          // EMPTY CART
          await DatabaseHelper.instance.clearUserCart(storage.read(USERID));
          await fetchAllCartItems();
          Get.closeAllSnackbars();
        }
      }
    } catch (e) {
      log("Error saving order: ${e.toString()}");
    } finally {
      isPaymentLoading.value = false;
    }
  }

  // STEP 4: Payment Success Handler
  // void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  //   log(
  //     "Payment Success: :  : : : : : : : : : : : : : :  : :${response.paymentId}",
  //   );
  //   log(response.data.toString());
  //   log(response.toString());
  //   try {
  //     if (response.paymentId != null) {
  //       String paymentMethod = await fetchPaymentMethod(
  //         response.paymentId ?? '',
  //       );

  //       final fullAddress =
  //           "${authController.fullName.trim()}, ${authController.address.trim()}, ${authController.cityName.trim()}, ${authController.stateName.trim()}, ${authController.zipcode.trim()}";
  //       // INSERT ORDER IN DB
  //       final order = OrderModel(
  //         orderStatus: 'Paid',
  //         userId: storage.read(USERID),
  //         razorpaySignature: response.signature ?? '',
  //         orderDate: DateTime.now().toString(),
  //         razorpayOrderId: response.orderId ?? '',
  //         razorpayPaymentId: response.paymentId ?? '',
  //         shippingAddress: fullAddress,
  //         customerName: storage.read(USERNAME),
  //         paymentMethod: paymentMethod,
  //         totalAmount: total.value,
  //         totalQuantity: totalQty,
  //         latitude: authController.lati,
  //         longitude: authController.longi,
  //       );

  //       final int? orderID = await DatabaseHelper.instance.insertOrder(order);
  //       if (orderID != null) {
  //         for (var item in cartItems) {
  //           for (int i = 1; i<=item.qty;i++){
  //             await DatabaseHelper.instance
  //           }
  //             await DatabaseHelper.instance.deductStock(
  //               productID: item.productId,
  //               qty: cartItemQty[item.productId] ?? 0,
  //             );
  //         }
  //         AppSnackbars.success('Success', 'Payment completed and order placed');
  //         Get.off(() => OrderSuccessScreen());

  //         // EMPTY CART
  //         await DatabaseHelper.instance.clearUserCart(storage.read(USERID));
  //         await fetchAllCartItems();
  //         Get.closeAllSnackbars();
  //       }
  //     }
  //   } catch (e) {
  //     log("Error saving order: ${e.toString()}");
  //   } finally {
  //     isPaymentLoading.value = false;
  //   }
  // }

  Future<String> fetchPaymentMethod(String paymentId) async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$key_id:$key_secret'))}';
    final response = await http.get(
      Uri.parse('https://api.razorpay.com/v1/payments/$paymentId'),
      headers: {'Authorization': basicAuth},
    );
    log(
      ": : : : : : : :response from payment method : : : : : :${response.body}",
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['method'];
    } else {
      log('Failed to fetch payment details');
      return "";
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    final code = response.code;
    final message = response.message?.toLowerCase() ?? '';

    log("Payment Failed [$code]: $message");

    String userMessage;

    if (message.contains('cancelled') || code == 2) {
      userMessage = 'Payment was cancelled by you.';
    } else if (message.contains('network') || message.contains('timeout')) {
      userMessage = 'Network error occurred. Please try again.';
    } else if (message.contains('insufficient funds') ||
        message.contains('insufficient balance')) {
      userMessage = 'Payment failed due to insufficient balance.';
    } else if (message.contains('invalid payment method')) {
      userMessage = 'Invalid payment method. Please choose another option.';
    } else if (message.contains('authentication') || message.contains('otp')) {
      userMessage =
          'Authentication failed. Please enter correct OTP or try again.';
    } else if (code == 0) {
      userMessage = 'An unexpected error occurred. Please try again later.';
    } else {
      userMessage = 'Payment failed: ${response.message ?? 'Unknown error'}';
    }

    Get.closeAllSnackbars();
    AppSnackbars.error('Payment Failed', userMessage);

    isPaymentLoading.value = false;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.closeAllSnackbars();
    AppSnackbars.warning('External Wallet', '${response.walletName}');
    isPaymentLoading.value = false;
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}
