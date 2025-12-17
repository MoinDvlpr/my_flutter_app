import 'dart:developer';
import 'dart:math' as math;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../utils/app_constant.dart';

class InitialDataFill {
  static fillInitialData({required Database db}) async {
    // Add default admin
    await db.insert(USERS, {
      USERNAME: 'admin',
      CONTACT: 1234567890,
      EMAIL: 'admin@example.com',
      PASSWORD: 'admin123',
      ROLE: 'admin',
      IS_ACTIVE: 1,
    });

    // Bulk insert categories
    await db.insert(CATEGORIES, {CATEGORY_NAME: 'Men', IS_ACTIVE: 1});
    await db.insert(CATEGORIES, {CATEGORY_NAME: 'Women', IS_ACTIVE: 1});
    await db.insert(CATEGORIES, {CATEGORY_NAME: 'Kids', IS_ACTIVE: 1});
    await db.insert(CATEGORIES, {CATEGORY_NAME: 'Accessories', IS_ACTIVE: 1});
    await db.insert(CATEGORIES, {CATEGORY_NAME: 'Shoes', IS_ACTIVE: 1});

    for (int i = 1; i <= 5; i++) {
      await db.insert(CATEGORIES, {CATEGORY_NAME: 'Category $i', IS_ACTIVE: 1});
    }

    // Bulk insert discount groups
    await db.insert(DISCOUNT_GROUPS, {
      GROUP_NAME: 'Bronze',
      DISCOUNT_PERCENTAGE: 5,
      IS_ACTIVE: 1,
    });
    await db.insert(DISCOUNT_GROUPS, {
      GROUP_NAME: 'Silver',
      DISCOUNT_PERCENTAGE: 10,
      IS_ACTIVE: 1,
    });
    await db.insert(DISCOUNT_GROUPS, {
      GROUP_NAME: 'Gold',
      DISCOUNT_PERCENTAGE: 15,
      IS_ACTIVE: 1,
    });

    for (int i = 16; i < 20; i++) {
      await db.insert(DISCOUNT_GROUPS, {
        GROUP_NAME: 'Discount $i',
        DISCOUNT_PERCENTAGE: i,
        IS_ACTIVE: 1,
      });
    }

    // Bulk insert users
    for (int i = 1; i <= 100; i++) {
      await db.insert(USERS, {
        USERNAME: 'user $i',
        CONTACT: 9000000000 + i,
        EMAIL: 'user$i@example.com',
        PASSWORD: 'password123',
        ROLE: 'User',
        IS_ACTIVE: i % 2 == 0 ? 1 : 0,
        GROUP_ID: (i % 3) + 1,
      });
    }

    // Bulk insert suppliers
    for (int i = 1; i <= 100; i++) {
      await db.insert(SUPPLIERS, {
        SUPPLIER_NAME: 'Supplier $i',
        CONTACT: 9000000000 + i,
        IS_DELETED: 0,
        IS_ACTIVE: i % 2 == 0 ? 1 : 0,
      });
    }

    // Bulk insert products
    List<String> images = [
      '/storage/emulated/0/Download/wdr2.jpg',
      '/storage/emulated/0/Download/wdr1.jpg',
      '/storage/emulated/0/Download/wd3.jpg',
    ];
    String imagePaths = images.join(',');

    // Create products with initial stock
    for (int i = 1; i <= 100; i++) {
      final productId = await db.insert(PRODUCTS, {
        PRODUCT_NAME: 'Product $i',
        SERIAL_NUMBER: 'INIT-SR-$i',
        PRODUCT_IMAGE: imagePaths,
        DESCRIPTION: 'Description for product $i',
        PRICE: (100 + i).toDouble(),
        MARKET_RATE: (150 + i).toDouble(),
        STOCK_QTY: 10, // Initial stock: 10 units
        SOLD_QTY: 0, // Will be updated during order creation
        INSERT_DATE: DateTime.now().toIso8601String(),
        CATEGORY_ID: (i % 5) + 1,
        IS_ACTIVE: 1,
      });

      // Create inventory record for each product
      final inventoryId = await db.insert(INVENTORY, {
        PRODUCT_ID: productId,
        PURCHASE_ORDER_ID: null,
        PRODUCT_BATCH: 1,
        REMAINING: 10, // Initial 10 units
        SELLING_PRICE: (100 + i).toDouble(),
        COST_PER_UNIT: (55 + i).toDouble(),
        IS_READY_FOR_SALE: 1,
        PURCHASE_DATE: DateTime.now().toIso8601String(),
      });

      // Create 10 inventory items (serial numbers) per product
      for (int j = 1; j <= 10; j++) {
        await db.insert(INVENTORY_ITEMS, {
          INVENTORY_ID: inventoryId,
          SERIAL_NUMBER:
              'SR-$productId-${Uuid().v4().replaceAll('-', '').substring(0, 8).toUpperCase()}-$j',
          IS_SOLD: 0,
        });
      }
    }

    // Create dummy orders with proper stock management
    List<String> statuses = [
      'Paid',
      'Delivered',
      'Processing',
      'Cancelled',
      'Shipped',
    ];
    List<String> paymentMethods = ['Razorpay', 'Cash on Delivery', 'UPI'];
    final random = math.Random();

    log('Starting order creation...');

    for (int orderNum = 1; orderNum <= 50; orderNum++) {
      int userId = (orderNum % 100) + 1;
      String customerName = "User $userId";
      String shippingAddress =
          "Address $userId, City ${orderNum % 10}, State ${orderNum % 5}";
      final latitude = 8.0 + random.nextDouble() * (37.0 - 8.0);
      final longitude = 68.0 + random.nextDouble() * (97.0 - 68.0);

      // Random number of different products in order (1-3)
      int numProducts = random.nextInt(3) + 1;
      double totalAmount = 0;
      int totalQty = 0;

      final List<Map<String, dynamic>> orderItemsToInsert = [];

      // Get available products with stock
      final availableProducts = await db.rawQuery('''
    SELECT p.*, i.$INVENTORY_ID
    FROM $PRODUCTS p
    INNER JOIN $INVENTORY i ON p.$PRODUCT_ID = i.$PRODUCT_ID
    WHERE p.$STOCK_QTY > 0 AND i.$REMAINING > 0
    ORDER BY RANDOM()
    LIMIT $numProducts
  ''');

      if (availableProducts.isEmpty) {
        log('⚠️ No available products for order $orderNum');
        continue;
      }

      for (final product in availableProducts) {
        int productId = product[PRODUCT_ID] as int;
        int inventoryId = product[INVENTORY_ID] as int;
        double price = product[PRICE] as double;
        int availableStock = product[STOCK_QTY] as int;

        // Random quantity for this product (1-3, but not more than available)
        int qtyToOrder = math.min(random.nextInt(3) + 1, availableStock);
        if (qtyToOrder == 0) continue;

        // Get unsold serial numbers for this inventory
        final inventoryItems = await db.query(
          INVENTORY_ITEMS,
          where: '$INVENTORY_ID = ? AND $IS_SOLD = 0',
          whereArgs: [inventoryId],
          limit: qtyToOrder,
        );

        if (inventoryItems.length < qtyToOrder) {
          log('⚠️ Not enough inventory items for product $productId');
          continue;
        }

        // Collect serial numbers
        List<String> serialNumbers = [];
        List<int> itemIdsToMarkSold = [];

        for (var item in inventoryItems) {
          serialNumbers.add(item[SERIAL_NUMBER] as String);
          itemIdsToMarkSold.add(item[INVENTORY_ITEM_ID] as int);
        }

        // Calculate item total
        double itemTotal = price * qtyToOrder;
        totalAmount += itemTotal;
        totalQty += qtyToOrder;

        // Add to order items
        orderItemsToInsert.add({
          PRODUCT_ID: productId,
          ITEM_NAME: product[PRODUCT_NAME],
          SERIAL_NUMBERS: serialNumbers.join(
            ',',
          ), // Comma-separated serial numbers
          ITEM_QTY: qtyToOrder,
          ITEM_IMAGE: product[PRODUCT_IMAGE],
          ITEM_DESCRIPTION: product[DESCRIPTION],
          ITEM_PRICE: price,
          DISCOUNT_PERCENTAGE: 5.0,
        });

        // ✅ Mark inventory items as sold
        for (int itemId in itemIdsToMarkSold) {
          await db.update(
            INVENTORY_ITEMS,
            {IS_SOLD: 1},
            where: '$INVENTORY_ITEM_ID = ?',
            whereArgs: [itemId],
          );
        }

        // ✅ Update inventory remaining
        await db.rawUpdate(
          '''
      UPDATE $INVENTORY
      SET $REMAINING = $REMAINING - ?
      WHERE $INVENTORY_ID = ?
    ''',
          [qtyToOrder, inventoryId],
        );

        // ✅ Update product stock_qty and sold_qty
        await db.rawUpdate(
          '''
      UPDATE $PRODUCTS
      SET $STOCK_QTY = $STOCK_QTY - ?,
          $SOLD_QTY = $SOLD_QTY + ?
      WHERE $PRODUCT_ID = ?
    ''',
          [qtyToOrder, qtyToOrder, productId],
        );
      }

      if (orderItemsToInsert.isEmpty) {
        log('⚠️ No items to add for order $orderNum');
        continue;
      }

      // ✅ Insert order
      final orderId = await db.insert(ORDERS, {
        USERID: userId,
        ORDER_STATUS: statuses[random.nextInt(statuses.length)],
        ORDER_DATE: DateTime.now()
            .subtract(Duration(days: random.nextInt(30)))
            .toIso8601String(),
        SHIPPING_ADDRESS: shippingAddress,
        CUSTOMER_NAME: customerName,
        PAYMENT_METHOD: paymentMethods[random.nextInt(paymentMethods.length)],
        // RP_ORDER_ID: 'RP_${DateTime.now().millisecondsSinceEpoch}_$orderNum',
        PAYMENT_INTENT_ID:
            'RP_${DateTime.now().millisecondsSinceEpoch}_$orderNum',
        PAYMENT_STATUS: "PAID",
        TOTAL_QTY: totalQty,
        DELIVERY_CHARGE: 150.0,
        TOTAL_AMOUNT: totalAmount + 150.0,
        LATITUDE: latitude,
        LONGITUDE: longitude,
      });

      // ✅ Insert order items
      for (final item in orderItemsToInsert) {
        await db.insert(ORDER_ITEMS, {ORDERID: orderId, ...item});
      }

      log('✅ Order $orderNum created: $totalQty items, ₹$totalAmount');
    }

    log('✅ Dummy data insertion completed successfully.');
    log(
      '✅ All stock quantities, sold quantities, and serial numbers are properly maintained.',
    );

    // Insert initial metadata
    await db.insert(CHAT_METADATA, {
      'last_reset': DateTime.now().toIso8601String(),
    });
  }
}
