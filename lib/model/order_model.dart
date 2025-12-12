import '../utils/app_constant.dart';

class OrderModel {
  int? orderId;
  int? userId;
  String orderStatus;
  String orderDate;
  String shippingAddress;
  String customerName;
  String paymentMethod;
  String? razorpayOrderId;
  String? razorpayPaymentId;
  String? razorpaySignature;
  double latitude;
  double longitude;
  int totalQuantity;
  double totalAmount;
  double deliveryCharge;

  OrderModel({
    this.orderId,
    this.userId,
    required this.orderStatus,
    required this.orderDate,
    required this.shippingAddress,
    required this.customerName,
    required this.paymentMethod,
    required this.latitude,
    required this.longitude,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
    required this.totalQuantity,
    required this.totalAmount,
    required this.deliveryCharge,
  });

  Map<String, dynamic> toMap() {
    return {
      if (orderId != null) ORDERID: orderId,
      USERID: userId,
      ORDER_STATUS: orderStatus,
      ORDER_DATE: orderDate,
      SHIPPING_ADDRESS: shippingAddress,
      CUSTOMER_NAME: customerName,
      PAYMENT_METHOD: paymentMethod,
      RP_ORDER_ID: razorpayOrderId,
      RP_PAYMENT_ID: razorpayPaymentId,
      RP_SIGNATURE: razorpaySignature,
      TOTAL_QTY: totalQuantity,
      DELIVERY_CHARGE: deliveryCharge,
      TOTAL_AMOUNT: totalAmount,
      LATITUDE: latitude,
      LONGITUDE: longitude,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map[ORDERID],
      userId: map[USERID],
      orderStatus: map[ORDER_STATUS],
      orderDate: map[ORDER_DATE],
      shippingAddress: map[SHIPPING_ADDRESS],
      customerName: map[CUSTOMER_NAME],
      paymentMethod: map[PAYMENT_METHOD],
      razorpayOrderId: map[RP_ORDER_ID],
      razorpayPaymentId: map[RP_PAYMENT_ID],
      razorpaySignature: map[RP_SIGNATURE],
      totalQuantity: map[TOTAL_QTY],
      deliveryCharge: map[DELIVERY_CHARGE].toDouble(),
      totalAmount: map[TOTAL_AMOUNT].toDouble(),
      latitude: map[LATITUDE].toDouble(),
      longitude: map[LONGITUDE].toDouble(),
    );
  }
}
