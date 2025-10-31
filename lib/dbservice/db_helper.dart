import 'dart:developer';
import 'dart:math' as math;
import 'package:sqflite/sqflite.dart';
import '../model/address_model.dart';
import '../model/cart_model.dart';
import '../model/category_model.dart';
import '../model/discount_group_model.dart';
import '../model/inventory_item_model.dart';
import '../model/order_item_model.dart';
import '../model/order_model.dart';
import '../model/product_model.dart';
import '../model/profitdatamodel.dart';
import '../model/purchase_item_model.dart';
import '../model/purchase_order_model.dart';
import '../model/supplier_model.dart';
import '../model/usermodel.dart';
import '../utils/app_constant.dart';
import 'package:path/path.dart';
import '../utils/sr_generator.dart';
import '../widgets/app_snackbars.dart';

class DatabaseHelper {
  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    String path = join(await getDatabasesPath(), MYSTOREDB);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('PRAGMA foreign_keys = ON');
        // users
        await db.execute('''
  CREATE TABLE $USERS (
    $USERID INTEGER PRIMARY KEY AUTOINCREMENT,
    $USERNAME TEXT NOT NULL,
    $CONTACT INTEGER NOT NULL,
    $EMAIL TEXT UNIQUE COLLATE NOCASE NOT NULL,
    $PASSWORD TEXT NOT NULL,
    $ROLE TEXT NOT NULL,
    $GROUP_ID INTEGER,
    FOREIGN KEY ($GROUP_ID) REFERENCES $DISCOUNT_GROUPS($GROUP_ID) ON DELETE SET NULL
  )
''');
        await db.execute('''
  CREATE TABLE $CATEGORIES (
    $CATEGORY_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    $CATEGORY_NAME TEXT UNIQUE COLLATE NOCASE NOT NULL
  )
''');

        await db.execute('''
CREATE TABLE $PRODUCTS (
  $PRODUCT_ID INTEGER PRIMARY KEY AUTOINCREMENT,
  $PRODUCT_NAME TEXT UNIQUE COLLATE NOCASE NOT NULL,
  $SERIAL_NUMBER TEXT UNIQUE,
  $PRODUCT_IMAGE TEXT NOT NULL,
  $DESCRIPTION TEXT,
  $PRICE REAL NOT NULL,
  $MARKET_RATE REAL NOT NULL,
  $STOCK_QTY INTEGER NOT NULL,
  $SOLD_QTY INTEGER NOT NULL,
  $INSERT_DATE TEXT NOT NULL,
  $CATEGORY_ID INTEGER,
  FOREIGN KEY ($CATEGORY_ID) REFERENCES $CATEGORIES($CATEGORY_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
''');
        await db.execute('''
CREATE TABLE $FAVORITES (
  $FAVORITE_ID INTEGER PRIMARY KEY AUTOINCREMENT,
  $PRODUCT_ID INTEGER,
  $USERID INTEGER,
  FOREIGN KEY ($PRODUCT_ID) REFERENCES $PRODUCTS($PRODUCT_ID)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  FOREIGN KEY ($USERID) REFERENCES $USERS($USERID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
''');
        await db.execute('''
            CREATE TABLE $DISCOUNT_GROUPS (
            $GROUP_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            $GROUP_NAME TEXT UNIQUE COLLATE NOCASE NOT NULL,
            $DISCOUNT_PERCENTAGE REAL NOT NULL
        );
        ''');

        await db.execute('''
        CREATE TABLE $CART (
  $CART_ID INTEGER PRIMARY KEY AUTOINCREMENT,
 
  $USERID INTEGER,
  $PRODUCT_ID INTEGER,
  $PRODUCT_QTY INTEGER,
  FOREIGN KEY ($USERID) REFERENCES $USERS($USERID)  ON DELETE CASCADE,
  FOREIGN KEY ($PRODUCT_ID) REFERENCES $PRODUCTS($PRODUCT_ID) ON DELETE CASCADE
);
        ''');

        await db.execute('''
        CREATE TABLE $SUPPLIERS (
        $SUPPLIER_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        $SUPPLIER_NAME TEXT NOT NULL,
        $CONTACT INTEGER,
        $IS_DELETED INTEGER NOT NULL 
        );
        ''');

        await db.execute(''' 
        CREATE TABLE $PURCHASE_ORDERS (
        $PURCHASE_ORDER_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        $IS_RECEIVED INTEGER NOT NULL,
        $SUPPLIER_ID INTEGER NOT NULL,
        $ORDER_DATE TEXT NOT NULL,
        $TOTAL_QTY INTEGER,
        $TOTAL_COST REAL NOT NULL,
        $IS_PARTIALLY_RECIEVED INTEGER NOT NULL,
        FOREIGN KEY ($SUPPLIER_ID) REFERENCES $SUPPLIERS($SUPPLIER_ID)
        );''');

        await db.execute('''
        CREATE TABLE $PURCHASE_ORDER_ITEMS (
        $PURCHASE_ITEM_ID INTEGER PRIMARY KEY AUTOINCREMENT,
       $SERIAL_NUMBER TEXT,
        $PURCHASE_ORDER_ID INTEGER NOT NULL,
        $PRODUCT_ID INTEGER NOT NULL,
        $QUANTITY INTEGER NOT NULL,
        $COST_PER_UNIT REAL NOT NULL,
        $IS_RECEIVED INTEGER NOT NULL,
        FOREIGN KEY ($PURCHASE_ORDER_ID) REFERENCES $PURCHASE_ORDERS(PURCHASE_ORDER_ID),
        FOREIGN KEY ($PRODUCT_ID) REFERENCES $PRODUCTS($PRODUCT_ID)
        );
''');

        await db.execute('''
        CREATE TABLE 
        $INVENTORY_ITEMS (
        $INVENTORY_ITEM_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        $INVENTORY_QUANTITY INTEGER NOT NULL,
        $PRODUCT_ID INTEGER NOT NULL,
        $SERIAL_NUMBER TEXT NOT NULL UNIQUE,
        $SELLING_PRICE REAL NOT NULL,
        FOREIGN KEY ($PRODUCT_ID) REFERENCES $PRODUCTS($PRODUCT_ID)
        );''');

        await db.execute('''
  CREATE TABLE $ADDRESSES (
    $ADDRESS_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    $USERID INTEGER,
    $FULL_NAME TEXT NOT NULL,
    $PHONE INTEGER NOT NULL,
    $ADDRESS TEXT NOT NULL,
    $CITY TEXT NOT NULL,
    $STATE TEXT NOT NULL,
    $COUNTRY TEXT NOT NULL,
    $ZIPCODE TEXT NOT NULL,
    $IS_DEFAULT INTEGER NOT NULL,

  $LATITUDE DOUBLE,
  $LONGITUDE DOUBLE,
    FOREIGN KEY ($USERID) REFERENCES $USERS($USERID) 
    ON DELETE CASCADE
    ON UPDATE CASCADE
  )
''');
        await db.execute('''
CREATE TABLE $ORDERS (
  $ORDERID INTEGER PRIMARY KEY AUTOINCREMENT,
  $USERID INTEGER,
  $LATITUDE DOUBLE,
  $LONGITUDE DOUBLE,
  $ORDER_STATUS TEXT NOT NULL,
  $ORDER_DATE TEXT NOT NULL,
  $SHIPPING_ADDRESS TEXT NOT NULL,
  $CUSTOMER_NAME TEXT NOT NULL,
  $PAYMENT_METHOD TEXT NOT NULL,
  $RP_ORDER_ID TEXT,
  $RP_PAYMENT_ID TEXT,
  $RP_SIGNATURE TEXT,
  $TOTAL_QTY INTEGER NOT NULL,
  $TOTAL_AMOUNT REAL NOT NULL
);
''');

        await db.execute('''
  CREATE TABLE $ORDER_ITEMS (
    $ITEM_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    $PRODUCT_ID INTEGER NOT NULL,
    $ORDERID INTEGER,
    $ITEM_NAME TEXT NOT NULL,
    $SERIAL_NUMBER TEXT NOT NULL,
    $ITEM_IMAGE TEXT NOT NULL,
    $ITEM_DESCRIPTION TEXT,
    $ITEM_PRICE REAL NOT NULL,
    $ITEM_QTY INTEGER NOT NULL,
    FOREIGN KEY ($ORDERID) REFERENCES $ORDERS($ORDERID) 
    FOREIGN KEY ($PRODUCT_ID) REFERENCES $PRODUCTS($PRODUCT_ID) 
    ON DELETE CASCADE
    ON UPDATE CASCADE
  );
''');

        // Add default admin
        await db.insert(USERS, {
          USERNAME: 'admin',
          CONTACT: 1234567890,
          EMAIL: 'admin@example.com',
          PASSWORD: 'admin123',
          ROLE: 'admin',
        });

        // Bulk insert categories
        await db.insert(CATEGORIES, {CATEGORY_NAME: 'Men'});
        await db.insert(CATEGORIES, {CATEGORY_NAME: 'Women'});
        await db.insert(CATEGORIES, {CATEGORY_NAME: 'Kids'});
        await db.insert(CATEGORIES, {CATEGORY_NAME: 'Accessories'});
        await db.insert(CATEGORIES, {CATEGORY_NAME: 'Shoes'});

        for (int i = 1; i <= 50; i++) {
          await db.insert(CATEGORIES, {CATEGORY_NAME: 'Category $i'});
        }

        // Bulk insert discount groups
        await db.insert(DISCOUNT_GROUPS, {
          GROUP_NAME: 'Bronze',
          DISCOUNT_PERCENTAGE: 5,
        });
        await db.insert(DISCOUNT_GROUPS, {
          GROUP_NAME: 'Silver',
          DISCOUNT_PERCENTAGE: 10,
        });
        await db.insert(DISCOUNT_GROUPS, {
          GROUP_NAME: 'Gold',
          DISCOUNT_PERCENTAGE: 15,
        });

        for (int i = 16; i < 100; i++) {
          await db.insert(DISCOUNT_GROUPS, {
            GROUP_NAME: 'Discount $i',
            DISCOUNT_PERCENTAGE: i,
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
            GROUP_ID: (i % 3) + 1,
          });
        }

        // Bulk insert products
        List<String> images = [
          '/storage/emulated/0/Download/wdr2.jpg',
          '/storage/emulated/0/Download/wdr1.jpg',
          '/storage/emulated/0/Download/wd3.jpg',
        ];
        String imagePaths = images.join(',');

        for (int i = 1; i <= 1000; i++) {
          await db.insert(PRODUCTS, {
            PRODUCT_NAME: 'Product $i',
            SERIAL_NUMBER: 'INIT-SR-$i',
            PRODUCT_IMAGE: imagePaths,
            DESCRIPTION: 'Description for product $i',
            PRICE: (100 + i).toDouble(),
            MARKET_RATE: (15000 + i % (i + 1)).toDouble(),
            STOCK_QTY: 50 + i,
            SOLD_QTY: i,
            INSERT_DATE: DateTime.now().toIso8601String(),
            CATEGORY_ID: (i % 5) + 1,
          });
        }
        // Constants
        List<String> statuses = [
          'Paid',
          'Delivered',
          'Processing',
          'Cancelled',
          'Shipped',
        ];
        List<String> paymentMethods = ['Razorpay', 'Cash on Delivery', 'UPI'];

        final random = math.Random();

        // Get all products (just once)
        final productList = await db.query(PRODUCTS);

        // Bulk insert orders and items
        for (int i = 1; i <= 1000; i++) {
          int userId = (i % 100) + 1;
          int addressId = (i % 100) + 1;
          final latitude = 8.0 + random.nextDouble() * (37.0 - 8.0);
          final longitude = 68.0 + random.nextDouble() * (97.0 - 68.0);
          // Use dummy address and customer info
          String customerName = "User $userId";
          String shippingAddress = "Address $addressId";

          // Select random number of items for this order
          int itemCount = random.nextInt(5) + 1;

          double totalAmount = 0.0;
          int totalQty = 0;

          // Pick random products for this order
          final items = List.generate(itemCount, (index) {
            final product = productList[random.nextInt(productList.length)];
            int qty = random.nextInt(3) + 1;
            double price = product[PRICE] as double;
            totalAmount += price * qty;
            totalQty += qty;

            // Generate a dummy serial for order item
            final String orderItemSr = 'ORDER-SR-${i}-ITEM-${index + 1}';

            return {

              ITEM_NAME: product[PRODUCT_NAME],
              PRODUCT_ID:product[PRODUCT_ID],
              SERIAL_NUMBER: orderItemSr,
              ITEM_IMAGE: product[PRODUCT_IMAGE],
              ITEM_DESCRIPTION: product[DESCRIPTION],
              ITEM_PRICE: price,
              ITEM_QTY: qty,
            };
          });

          // Insert into ORDERS
          int orderId = await db.insert(ORDERS, {
            USERID: userId,
            ORDER_STATUS: statuses[random.nextInt(statuses.length)],
            ORDER_DATE: DateTime.now()
                .subtract(Duration(days: random.nextInt(30)))
                .toIso8601String(),
            SHIPPING_ADDRESS: shippingAddress,
            CUSTOMER_NAME: customerName,
            PAYMENT_METHOD:
            paymentMethods[random.nextInt(paymentMethods.length)],
            RP_ORDER_ID: null,
            RP_PAYMENT_ID: null,
            RP_SIGNATURE: null,
            TOTAL_QTY: totalQty,
            TOTAL_AMOUNT: totalAmount,
            LATITUDE: latitude,
            LONGITUDE: longitude,
          });

          // Insert ORDER_ITEMS
          for (final item in items) {
            await db.insert(ORDER_ITEMS, {ORDERID: orderId, ...item});
          }
        }

        // Bulk insert suppliers
        for (int i = 1; i <= 100; i++) {
          await db.insert(SUPPLIERS, {
            SUPPLIER_NAME: 'Supplier $i',
            CONTACT: 9000000000 + i,
            IS_DELETED: 0,
          });
        }

        // Add this code after the supplier bulk insert in your _initDatabase() method
// (after the "Bulk insert suppliers" section)

// Bulk insert purchase orders with items

        final productsList = await db.query(PRODUCTS, limit: 100);

        for (int i = 1; i <= 50; i++) {
          final supplierId = (i % 100) + 1;
          final orderDate = DateTime.now().subtract(Duration(days: random.nextInt(90)));
          final isReceived = random.nextInt(10) > 6 ? 1 : 0; // 30% received
          final isPartiallyReceived = isReceived == 0 && random.nextBool() ? 1 : 0;

          // Generate 3-8 items per order
          final itemCount = random.nextInt(6) + 3;
          final selectedProducts = List.generate(
            itemCount,
                (_) => productsList[random.nextInt(productsList.length)],
          );

          int totalQty = 0;
          double totalCost = 0.0;

          // Calculate totals
          for (var product in selectedProducts) {
            final qty = random.nextInt(20) + 5;
            final costPerUnit = (product[PRICE] as double) * 0.7; // 70% of selling price
            totalQty += qty;
            totalCost += costPerUnit * qty;
          }

          // Insert purchase order
          final poId = await db.insert(PURCHASE_ORDERS, {
            IS_RECEIVED: isReceived,
            SUPPLIER_ID: supplierId,
            ORDER_DATE: orderDate.toIso8601String(),
            TOTAL_QTY: totalQty,
            TOTAL_COST: totalCost,
            IS_PARTIALLY_RECIEVED: isPartiallyReceived,
          });


          // Insert purchase order items (with realistic variation)
          for (var product in selectedProducts) {
            final productId = product[PRODUCT_ID] as int;
            final qty = random.nextInt(20) + 5;

            // Randomize cost: sometimes higher (loss), sometimes lower (profit)
            final price = product[PRICE] as double;
            final double variation = random.nextBool() ? 0.8 : 1.2; // 80% = profit, 120% = loss
            final double costPerUnit = price * variation * 0.7; // adjust baseline cost

            final srNo = SRGenerator.generateSR(productId, poId);

            await db.insert(PURCHASE_ORDER_ITEMS, {
              SERIAL_NUMBER: srNo,
              PURCHASE_ORDER_ID: poId,
              PRODUCT_ID: productId,
              QUANTITY: qty,
              COST_PER_UNIT: costPerUnit,
              IS_RECEIVED: isReceived,
            });

            // If received, add to inventory and update stock
            if (isReceived == 1) {
              final sellingPrice = price;

              await db.insert(INVENTORY_ITEMS, {
                INVENTORY_QUANTITY: qty,
                PRODUCT_ID: productId,
                SERIAL_NUMBER: srNo,
                SELLING_PRICE: sellingPrice,
              });

              final currentStock = product[STOCK_QTY] as int;
              await db.update(
                PRODUCTS,
                {STOCK_QTY: currentStock + qty},
                where: '$PRODUCT_ID = ?',
                whereArgs: [productId],
              );
            }
          }
        }

        // Bulk insert addresses

        final count =
            Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM $ADDRESSES'),
            ) ??
            0;
        if (count == 0) {
          final random = math.Random();
          for (int i = 1; i <= 100; i++) {
            final latitude = 8.0 + random.nextDouble() * (37.0 - 8.0);
            final longitude = 68.0 + random.nextDouble() * (97.0 - 68.0);
            await db.insert(ADDRESSES, {
              USERID: i,
              FULL_NAME: 'User $i',
              PHONE: 9876540000 + i,
              ADDRESS: 'Address $i',
              CITY: 'City $i',
              STATE: 'State $i',
              COUNTRY: 'India',
              ZIPCODE: 'ZIP $i',
              IS_DEFAULT: 1,
              LATITUDE: latitude,
              LONGITUDE: longitude,
            });
          }
        }

        // ---- INSERT DUMMY PROFIT & LOSS TEST DATA ----
        print('Inserting profit/loss test data...');

// Create a sample purchase order (COST DATA)
        final testPurchaseOrderId = await db.insert(PURCHASE_ORDERS, {
          IS_RECEIVED: 1,
          SUPPLIER_ID: 1,
          ORDER_DATE: '2025-10-20',
          TOTAL_QTY: 10,
          TOTAL_COST: 0,
          IS_PARTIALLY_RECIEVED: 0,
        });

// Manually insert known-cost purchase items
        final testItems = [
          // product_id, sr_no, cost_per_unit
          {'product_id': 1, 'sr_no': 'SR-P1', 'cost_per_unit': 100.0},
          {'product_id': 2, 'sr_no': 'SR-P2', 'cost_per_unit': 200.0},
          {'product_id': 3, 'sr_no': 'SR-P3', 'cost_per_unit': 500.0},
          {'product_id': 4, 'sr_no': 'SR-P4', 'cost_per_unit': 1000.0},
        ];

        for (final item in testItems) {
          await db.insert(PURCHASE_ORDER_ITEMS, {
            SERIAL_NUMBER: item['sr_no'],
            PURCHASE_ORDER_ID: testPurchaseOrderId,
            PRODUCT_ID: item['product_id'],
            QUANTITY: 10,
            COST_PER_UNIT: item['cost_per_unit'],
            IS_RECEIVED: 1,
          });
        }

// ---- CREATE SALES ORDERS ----

// 1️⃣ PROFIT day (sell higher than cost)
        final orderProfitId = await db.insert(ORDERS, {
          USERID: 1,
          ORDER_STATUS: 'Delivered',
          ORDER_DATE: '2025-10-21',
          SHIPPING_ADDRESS: 'Test Address 1',
          CUSTOMER_NAME: 'Profit Customer',
          PAYMENT_METHOD: 'Cash on Delivery',
          TOTAL_QTY: 5,
          TOTAL_AMOUNT: 0,
          LATITUDE: 10.0,
          LONGITUDE: 70.0,
        });

        await db.insert(ORDER_ITEMS, {
          ORDERID: orderProfitId,
          PRODUCT_ID: 1,
          ITEM_NAME: 'Product 1',
          SERIAL_NUMBER: 'SR-P1',
          ITEM_IMAGE: '/storage/emulated/0/Download/wdr1.jpg',
          ITEM_DESCRIPTION: 'Profit case',
          ITEM_PRICE: 150.0, // sold above cost 100
          ITEM_QTY: 3,
        });
        await db.insert(ORDER_ITEMS, {
          ORDERID: orderProfitId,
          PRODUCT_ID: 2,
          ITEM_NAME: 'Product 2',
          SERIAL_NUMBER: 'SR-P2',
          ITEM_IMAGE: '/storage/emulated/0/Download/wdr2.jpg',
          ITEM_DESCRIPTION: 'Profit case',
          ITEM_PRICE: 300.0, // sold above cost 200
          ITEM_QTY: 2,
        });

// 2️⃣ LOSS day (sell lower than cost)
        final orderLossId = await db.insert(ORDERS, {
          USERID: 1,
          ORDER_STATUS: 'Delivered',
          ORDER_DATE: '2025-10-22',
          SHIPPING_ADDRESS: 'Test Address 2',
          CUSTOMER_NAME: 'Loss Customer',
          PAYMENT_METHOD: 'UPI',
          TOTAL_QTY: 6,
          TOTAL_AMOUNT: 0,
          LATITUDE: 11.0,
          LONGITUDE: 72.0,
        });

        await db.insert(ORDER_ITEMS, {
          ORDERID: orderLossId,
          PRODUCT_ID: 3,
          ITEM_NAME: 'Product 3',
          SERIAL_NUMBER: 'SR-P3',
          ITEM_IMAGE: '/storage/emulated/0/Download/wd3.jpg',
          ITEM_DESCRIPTION: 'Loss case',
          ITEM_PRICE: 400.0, // sold below cost 500
          ITEM_QTY: 3,
        });
        await db.insert(ORDER_ITEMS, {
          ORDERID: orderLossId,
          PRODUCT_ID: 4,
          ITEM_NAME: 'Product 4',
          SERIAL_NUMBER: 'SR-P4',
          ITEM_IMAGE: '/storage/emulated/0/Download/wdr2.jpg',
          ITEM_DESCRIPTION: 'Loss case',
          ITEM_PRICE: 900.0, // sold below cost 1000
          ITEM_QTY: 3,
        });

        print('✅ Profit/loss test records inserted successfully.');

      },
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // Query Methods
  /////////////////////// Authentication ////////////////////////
  // login user
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      final db = await database;
      final result = await db.query(
        USERS,
        where: "$EMAIL = ? AND $PASSWORD = ?",
        whereArgs: [email, password],
      );
      if (result.isNotEmpty) {
        return result.first;
      }
      return null;
    } catch (e) {
      log("error (loginUser) : : : :  :${e.toString()}");
      return null;
    }
  }

  ////////////// Admin side //////////////
  // Dashboard
  // Total users
  Future<int> getTotalUsers() async {
    final db = await database;
    var result = await db.rawQuery(
      "SELECT COUNT(*) as total FROM $USERS WHERE $ROLE = ?",
      ['User'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Total products
  Future<int> getTotalProducts() async {
    final db = await database;
    var result = await db.rawQuery("SELECT COUNT(*) as total FROM $PRODUCTS");

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // total orders
  Future<int> getAllOrdersCounts() async {
    try {
      var db = await database;
      final result = await db.rawQuery('''
    SELECT COUNT(*) as count
    FROM $ORDERS
  ''');
      return result.first['count'] as int;
    } catch (e) {
      return 0;
    }
  }

  // Order summary (status-wise)
  Future<Map<String, int>> getOrderStatusSummary() async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT $ORDER_STATUS, COUNT(*) as count
    FROM $ORDERS
    GROUP BY $ORDER_STATUS
  ''');
    Map<String, int> statusSummary = {};
    for (var row in result) {
      statusSummary[row[ORDER_STATUS] as String] = row['count'] as int;
    }
    return statusSummary;
  }

  // Most selling product
  Future<List<ProductModel>> getMostSellingProduct({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        '''
    SELECT * FROM $PRODUCTS WHERE $SOLD_QTY > 0 ORDER BY $SOLD_QTY DESC LIMIT ? OFFSET ?
  ''',
        [limit, offset],
      );

      return result.isNotEmpty
          ? result.map((e) => ProductModel.fromMap(e)).toList()
          : [];
    } catch (e) {
      log("error (getMostSellingProduct) : : : : ${e.toString()}");
      return [];
    }
  }

  Future<int> getMostSellingProductTotalPages({required int pageSize}) async {
    final db = await database;

    final result = await db.rawQuery('''
    SELECT COUNT(*) as totalCount
    FROM $PRODUCTS
    WHERE $SOLD_QTY > 0
    ''');

    final totalCount = Sqflite.firstIntValue(result) ?? 0;

    return (totalCount / pageSize).ceil();
  }

  // get all users
  Future<List<UserModel>> getAllUsers({
    int limit = 20,
    int offset = 0,
    String? searchQuery,
  }) async {
    final db = await database;

    // Build WHERE clause manually
    final whereClauses = <String>["$ROLE = ?"];
    final args = <dynamic>['User'];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add("($USERNAME LIKE ?)");
      args.add('%$searchQuery%');
    }

    final whereString = whereClauses.isNotEmpty
        ? 'WHERE ${whereClauses.join(' AND ')}'
        : '';

    final result = await db.rawQuery(
      '''
    SELECT * FROM $USERS
    $whereString
    ORDER BY $USERNAME ASC
    LIMIT ? OFFSET ?
    ''',
      [...args, limit, offset],
    );

    return result.map((e) => UserModel.fromMap(e)).toList();
  }

  // get users total page
  Future<int> getUsersTotalPages({
    required int pageSize,
    String? searchQuery,
  }) async {
    final db = await database;

    // Build WHERE clause
    final whereClauses = <String>["$ROLE = ?"];
    final args = <dynamic>['User'];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add("($USERNAME LIKE ?)");
      args.add('%$searchQuery%');
    }

    final whereString = whereClauses.isNotEmpty
        ? 'WHERE ${whereClauses.join(' AND ')}'
        : '';

    final result = await db.rawQuery('''
    SELECT COUNT(*) as totalCount
    FROM $USERS
    $whereString
  ''', args);

    final totalCount = Sqflite.firstIntValue(result) ?? 0;
    return (totalCount / pageSize).ceil();
  }

  // delete database
  Future<void> deleteDB() async {
    String path = join(await getDatabasesPath(), MYSTOREDB);
    await deleteDatabase(path);
  }

  // Add User
  Future<int?> insertUser(UserModel user) async {
    try {
      var db = await database;
      var result = await db.insert(USERS, user.toMap());
      return result;
    } catch (e) {
      log("error (insertUser) : : : --> ${e.toString()}");
      if (e is DatabaseException &&
          e.toString().contains('UNIQUE constraint failed')) {
        AppSnackbars.warning('Duplicate user', "User already exists!");
        return 0;
      } else {
        return null;
      }
    }
  }

  // update password
  Future<int?> updatePassword({required newPassword, required userID}) async {
    try {
      var db = await database;
      return await db.update(
        USERS,
        {PASSWORD: newPassword},
        where: "$USERID =?",
        whereArgs: [userID],
      );
    } catch (e) {
      log("error (updatePassword) : : : : : ${e.toString()}");
      return null;
    }
  }

  // get user by id
  Future<Map<String, dynamic>?> getUserByID({required int userid}) async {
    final db = await database;
    final result = await db.query(
      USERS,
      where: "$USERID = ?",
      whereArgs: [userid],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Update User
  Future<int?> updateUser({
    required UserModel user,
    required int userid,
  }) async {
    try {
      var db = await database;
      var result = await db.update(
        USERS,
        user.toMap(),
        where: "$USERID = ?",
        whereArgs: [userid],
      );
      return result;
    } catch (e) {
      log("error (updateUser) : : : : -->  ${e.toString()}");
      if (e is DatabaseException &&
          e.toString().contains('UNIQUE constraint failed')) {
        AppSnackbars.warning('Duplicate user', "User already exists!");
        return 0;
      } else {
        return null;
      }
    }
  }

  // delete user
  Future<int?> deleteUser({required userid}) async {
    try {
      var db = await database;
      var result = await db.delete(
        USERS,
        where: "$USERID = ?",
        whereArgs: [userid],
      );

      return result;
    } catch (e) {
      log("error (deleteUser) : : : : --> ${e.toString()}");
      return null;
    }
  }

  /////////// get total page count of category /////////////
  Future<int> getTotalCategoryCount({String? searchQuery}) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> args = [];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClause = 'WHERE $CATEGORY_NAME LIKE ?';
      args.add('%$searchQuery%');
    }

    final result = await db.rawQuery('''
    SELECT COUNT(*) as totalCount
    FROM $CATEGORIES
    $whereClause
    ''', args);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /////////////////// Categories ////////////////////
  // get all categories
  Future<List<CategoryModel>> getAllCategories({
    int limit = 20,
    int offset = 0,
    String? searchQuery,
  }) async {
    try {
      final db = await database;

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final result = await db.rawQuery(
          '''
        SELECT * FROM $CATEGORIES WHERE $CATEGORY_NAME LIKE ?
        ORDER BY $CATEGORY_ID DESC
        LIMIT ? OFFSET ?
        ''',
          ['%$searchQuery%', limit, offset],
        );
        return result.map((e) => CategoryModel.fromMap(e)).toList();
      } else {
        final result = await db.rawQuery(
          '''
        SELECT * FROM $CATEGORIES 
        ORDER BY $CATEGORY_ID ASC
        LIMIT ? OFFSET ?
        ''',
          [limit, offset],
        );
        return result.map((e) => CategoryModel.fromMap(e)).toList();
      }
    } catch (e) {
      log("error (getAllCategories) ::::::--> ${e.toString()}");
      return [];
    }
  }

  /// total pages of categories ///
  Future<int> getTotalCategoryPages({
    int pageSize = 20,
    String? searchQuery,
  }) async {
    final totalItems = await getTotalCategoryCount(searchQuery: searchQuery);
    return (totalItems / pageSize).ceil();
  }

  // insert category
  Future<int?> insertCategory({required String catgoryname}) async {
    try {
      var db = await database;
      var result = await db.insert(CATEGORIES, {CATEGORY_NAME: catgoryname});
      return result;
    } catch (e) {
      log("error (insertCategory) : : : --> ${e.toString()}");
      if (e is DatabaseException &&
          e.toString().contains('UNIQUE constraint failed')) {
        AppSnackbars.warning('Duplicate category', "Category already exists!");
        return 0;
      } else {
        return null;
      }
    }
  }

  // update category
  Future<int?> updateCategory({
    required String catgoryname,
    required int catID,
  }) async {
    try {
      var db = await database;
      var result = await db.update(
        CATEGORIES,
        {CATEGORY_NAME: catgoryname},
        where: "$CATEGORY_ID=?",
        whereArgs: [catID],
      );
      return result;
    } catch (e) {
      if (e is DatabaseException &&
          e.toString().contains('UNIQUE constraint failed')) {
        AppSnackbars.warning('Duplicate category', "Category already exists!");
        return 0;
      } else {
        log("error (updateCategory) : : : --> ${e.toString()}");
        return null;
      }
    }
  }

  // delete category
  Future<int?> deleteCategory({required catID}) async {
    try {
      var db = await database;
      var result = await db.delete(
        CATEGORIES,
        where: "$CATEGORY_ID = ?",
        whereArgs: [catID],
      );

      return result;
    } catch (e) {
      log("error (deleteCategory) : : : : --> ${e.toString()}");
      return null;
    }
  }

  ////////////////////// Products //////////////////////
  // insert Product
  Future<int?> insertProduct({required ProductModel product}) async {
    try {
      var db = await database;
      product.srNo = "SR-${product.insertDate}";
      var result = await db.insert(PRODUCTS, product.toMap());
      if(result != 0) {
        final inventory =  InventoryItemModel(invQuantity: product.stockQty,productId: result, serialNumber: product.srNo ?? '', sellingPrice: product.price);
        await insertInventory(inventory);
      }
      return result;
    } catch (e) {
      log("error (insertProduct) : : : --> ${e.toString()}");
      if (e is DatabaseException &&
          e.toString().contains('UNIQUE constraint failed')) {
        AppSnackbars.warning('Duplicate product', "Product already exists!");
        return 0;
      } else {
        return null;
      }
    }
  }

  // single product for update
  Future<Map<String, dynamic>?> getProductByID({required int productID}) async {
    final db = await database;
    final result = await db.query(
      PRODUCTS,
      where: "$PRODUCT_ID = ?",
      whereArgs: [productID],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // update product
  Future<int?> updateProduct({required ProductModel product}) async {
    try {
      var db = await database;
      var result = await db.update(
        PRODUCTS,
        product.toMap(),
        where: "$PRODUCT_ID=?",
        whereArgs: [product.productId],
      );
      return result;
    } catch (e) {
      log("error (updateProduct) : : : --> ${e.toString()}");
      if (e is DatabaseException &&
          e.toString().contains('UNIQUE constraint failed')) {
        AppSnackbars.warning('Duplicate product', "Product already exists!");
        return 0;
      } else {
        return null;
      }
    }
  }

  // delete product
  Future<int?> deleteProduct({required productID}) async {
    try {
      var db = await database;
      var result = await db.delete(
        PRODUCTS,
        where: "$PRODUCT_ID = ?",
        whereArgs: [productID],
      );
      return result;
    } catch (e) {
      log("error (deleteProduct) : : : : --> ${e.toString()}");
      return null;
    }
  }

  /////////////////////// Discount Group //////////////////////
  /////////// get total page count of category /////////////
  Future<int> getTotalGroupCount({String? searchQuery}) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> args = [];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClause = 'WHERE $GROUP_NAME LIKE ?';
      args.add('%$searchQuery%');
    }

    final result = await db.rawQuery('''
    SELECT COUNT(*) as totalCount
    FROM $DISCOUNT_GROUPS
    $whereClause
    ''', args);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // get all groups
  Future<List<DiscountGroupModel>> getAllGroups({
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final db = await database;
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final result = await db.rawQuery(
          '''
        SELECT * FROM $DISCOUNT_GROUPS WHERE $GROUP_NAME LIKE ?
        ORDER BY $GROUP_ID DESC
        LIMIT ? OFFSET ?
        ''',
          ['%$searchQuery%', limit, offset],
        );
        return result.map((e) => DiscountGroupModel.fromMap(e)).toList();
      } else {
        final result = await db.rawQuery(
          '''
        SELECT * FROM $DISCOUNT_GROUPS 
        ORDER BY $GROUP_ID DESC
        LIMIT ? OFFSET ?
        ''',
          [limit, offset],
        );
        return result.map((e) => DiscountGroupModel.fromMap(e)).toList();
      }
    } catch (e) {
      log("error (getAllGroups) ::::::--> ${e.toString()}");
      return [];
    }
  }

  /// total pages of groups ///
  Future<int> getTotalGroupPages({
    int pageSize = 20,
    String? searchQuery,
  }) async {
    final totalItems = await getTotalGroupCount(searchQuery: searchQuery);
    return (totalItems / pageSize).ceil();
  }

  // get all search groups
  Future<List<DiscountGroupModel>> searchGroup(String query) async {
    try {
      final db = await database;
      final result = await db.query(
        DISCOUNT_GROUPS,
        where: "$GROUP_NAME LIKE ?",
        whereArgs: ['%${query.toString().toLowerCase().trim()}%'],
      );
      log("this is group result : : : ->> $result");
      return result.map((e) => DiscountGroupModel.fromMap(e)).toList();
    } catch (e) {
      log("error (searchGroup) ::::::--> ${e.toString()}");
      return [];
    }
  }

  // insert group
  Future<int?> insertGroup({required DiscountGroupModel group}) async {
    try {
      var db = await database;
      var result = await db.insert(DISCOUNT_GROUPS, group.toMap());
      return result;
    } catch (e) {
      log("error (insertGroup) : : : --> ${e.toString()}");
      if (e is DatabaseException &&
          e.toString().contains('UNIQUE constraint failed')) {
        AppSnackbars.warning('Duplicate group', "Group already exists!");
        return 0;
      } else {
        return null;
      }
    }
  }

  // get group by id
  Future<DiscountGroupModel?> getGroupByID({required groupID}) async {
    final db = await database;
    final result = await db.query(
      DISCOUNT_GROUPS,
      where: "$GROUP_ID = ?",
      whereArgs: [groupID],
    );
    if (result.isNotEmpty) {
      return DiscountGroupModel.fromMap(result.first);
    }
    return null;
  }

  // update group
  Future<int?> updateGroup({required DiscountGroupModel group}) async {
    try {
      var db = await database;
      var result = await db.update(
        DISCOUNT_GROUPS,
        group.toMap(),
        where: "$GROUP_ID=?",
        whereArgs: [group.groupId],
      );
      return result;
    } catch (e) {
      log("error (updateGroup) : : : --> ${e.toString()}");
      if (e is DatabaseException &&
          e.toString().contains('UNIQUE constraint failed')) {
        AppSnackbars.warning('Duplicate group', "Group already exists!");
        return 0;
      } else {
        return null;
      }
    }
  }

  // delete group
  Future<int?> deleteGroup({required groupID}) async {
    try {
      var db = await database;
      var result = await db.delete(
        DISCOUNT_GROUPS,
        where: "$GROUP_ID = ?",
        whereArgs: [groupID],
      );

      return result;
    } catch (e) {
      log("error (deleteGroup) : : : : --> ${e.toString()}");
      return null;
    }
  }

  // assign group to user
  Future<int?> updateUserGroup({required groupID, required userID}) async {
    try {
      var db = await database;
      var result = await db.update(
        USERS,
        {GROUP_ID: groupID},
        where: "$USERID = ?",
        whereArgs: [userID],
      );
      return result;
    } catch (e) {
      log("error (updateUserGroup) : : : -- > ${e.toString()}");
      return null;
    }
  }

  // get all orders
  Future<List<OrderModel>> getAllOrders({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        '''
      SELECT * FROM $ORDERS
      LIMIT ? OFFSET ?
      ''',
        [limit, offset],
      );
      return result.map((e) => OrderModel.fromMap(e)).toList();
    } catch (e) {
      log("error (getAllOrders) ::::::--> ${e.toString()}");
      return [];
    }
  }

  Future<int> getTotalOrderPages({int limit = 20}) async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $ORDERS');
      final count = Sqflite.firstIntValue(result) ?? 0;
      return (count / limit).ceil();
    } catch (e) {
      log("error (getTotalOrderPages) ::::::--> ${e.toString()}");
      return 0;
    }
  }

  Future<List<OrderModel>> getAllUserOrders(
    int userID, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final db = await database;
      final result = await db.query(
        ORDERS,
        where: "$USERID = ?",
        whereArgs: [userID],
        limit: limit,
        offset: offset,
        orderBy: '$ORDERID DESC',
      );
      return result.map((e) => OrderModel.fromMap(e)).toList();
    } catch (e) {
      log("error (getAllUserOrders) ::::::--> ${e.toString()}");
      return [];
    }
  }

  Future<int> getTotalPagesForUserOrders(int userID, {int limit = 20}) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $ORDERS WHERE $USERID = ?',
        [userID],
      );

      final count = Sqflite.firstIntValue(result) ?? 0;
      return (count / limit).ceil();
    } catch (e) {
      log("error (getTotalPagesForUserOrders) ::::::--> ${e.toString()}");
      return 0;
    }
  }

  Future<int?> updateStatus({
    required int orderID,
    required String status,
  }) async {
    try {
      var db = await database;
      return await db.update(
        ORDERS,
        {ORDER_STATUS: status},
        where: "$ORDERID =?",
        whereArgs: [orderID],
      );
    } catch (e) {
      log("error (updateStatus)");
      return null;
    }
  }

  //////////////////////// End Admin Side ///////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  //////////////////////// Start User Side ///////////////////////////////

  // user all product
  Future<List<ProductModel>> getAllProductsWithFavorite(int userId) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        '''
      SELECT
        p.$PRODUCT_ID,
        p.$PRODUCT_NAME,
        p.$DESCRIPTION,
        p.$PRICE,
        p.$STOCK_QTY,
        p.$SOLD_QTY,
        p.$PRODUCT_IMAGE,
        p.$CATEGORY_ID,
        p.$INSERT_DATE,
        c.$CATEGORY_NAME,
        CASE WHEN f.$PRODUCT_ID IS NOT NULL THEN 1 ELSE 0 END AS is_favorite,
        g.$DISCOUNT_PERCENTAGE,
        ROUND(
          CASE 
            WHEN g.$DISCOUNT_PERCENTAGE IS NOT NULL 
            THEN p.$PRICE - (p.$PRICE * g.$DISCOUNT_PERCENTAGE / 100)
            ELSE p.$PRICE 
          END, 2
        ) AS discounted_price
      FROM $PRODUCTS p
      JOIN $CATEGORIES c ON p.$CATEGORY_ID = c.$CATEGORY_ID
      LEFT JOIN $FAVORITES f 
        ON p.$PRODUCT_ID = f.$PRODUCT_ID AND f.$USERID = ?
      LEFT JOIN $USERS u ON u.$USERID = ?
      LEFT JOIN $DISCOUNT_GROUPS g ON u.$GROUP_ID = g.$GROUP_ID
      ORDER BY p.$PRODUCT_ID DESC
    ''',
        [userId, userId],
      );

      log("Products with favorites + discount: $result");
      log(result.toString());
      return result.map((e) => ProductModel.fromMap(e)).toList();
    } catch (e) {
      log("Error (getAllProductsWithFavorite): ${e.toString()}");
      return [];
    }
  }

  Future<int> getFilteredProductCount({
    required int userId,
    String? searchQuery,
    int? categoryId,
  }) async {
    final db = await database;

    final whereClauses = <String>[];
    final args = <dynamic>[userId, userId];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add("(p.$PRODUCT_NAME LIKE ? OR p.$DESCRIPTION LIKE ?)");
      args.addAll(['%$searchQuery%', '%$searchQuery%']);
    }

    if (categoryId != null) {
      whereClauses.add("p.$CATEGORY_ID = ?");
      args.add(categoryId);
    }

    final whereString = whereClauses.isNotEmpty
        ? 'WHERE ${whereClauses.join(' AND ')}'
        : '';

    final result = await db.rawQuery('''
    SELECT COUNT(*) as totalCount
    FROM $PRODUCTS p
    JOIN $CATEGORIES c ON p.$CATEGORY_ID = c.$CATEGORY_ID
    LEFT JOIN $FAVORITES f ON p.$PRODUCT_ID = f.$PRODUCT_ID AND f.$USERID = ?
    LEFT JOIN $USERS u ON u.$USERID = ?
    LEFT JOIN $DISCOUNT_GROUPS g ON u.$GROUP_ID = g.$GROUP_ID
    $whereString
    ''', args);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<ProductModel>> getFilteredProducts({
    required int userId,
    String? searchQuery,
    String? sortType,
    int? categoryId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final db = await database;

      // Build WHERE clause
      final whereClauses = <String>[];
      final args = <dynamic>[userId, userId];

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        whereClauses.add("(p.$PRODUCT_NAME LIKE ? OR p.$DESCRIPTION LIKE ?)");
        args.addAll(['%$searchQuery%', '%$searchQuery%']);
      }

      if (categoryId != null) {
        whereClauses.add("p.$CATEGORY_ID = ?");
        args.add(categoryId);
      }

      final whereString = whereClauses.isNotEmpty
          ? 'WHERE ${whereClauses.join(' AND ')}'
          : '';

      // Sorting logic
      String orderBy = 'p.$PRODUCT_ID DESC';

      switch (sortType) {
        case 'most_popular':
          orderBy = 'p.$SOLD_QTY DESC';
          break;
        case 'price_low_to_high':
          orderBy = 'discounted_price ASC';
          break;
        case 'price_high_to_low':
          orderBy = 'discounted_price DESC';
          break;
        case 'name_asc':
          orderBy = 'p.$PRODUCT_NAME ASC';
          break;
        case 'name_desc':
          orderBy = 'p.$PRODUCT_NAME DESC';
          break;
      }

      final result = await db.rawQuery(
        '''
      SELECT
        p.$PRODUCT_ID,
        p.$PRODUCT_NAME,
        p.$DESCRIPTION,
        p.$PRICE,
        p.$MARKET_RATE,
        p.$STOCK_QTY,
        p.$SOLD_QTY,
        p.$PRODUCT_IMAGE,
        p.$CATEGORY_ID,
        p.$INSERT_DATE,
        c.$CATEGORY_NAME,

        CASE WHEN f.$PRODUCT_ID IS NOT NULL THEN 1 ELSE 0 END AS is_favorite,

        g.$DISCOUNT_PERCENTAGE,
        

        ROUND(
          CASE 
            WHEN g.$DISCOUNT_PERCENTAGE IS NOT NULL 
            THEN p.$PRICE - (p.$PRICE * g.$DISCOUNT_PERCENTAGE / 100)
            ELSE p.$PRICE 
          END, 2
        ) AS discounted_price

      FROM $PRODUCTS p
      JOIN $CATEGORIES c ON p.$CATEGORY_ID = c.$CATEGORY_ID

      LEFT JOIN $FAVORITES f ON p.$PRODUCT_ID = f.$PRODUCT_ID AND f.$USERID = ?
      LEFT JOIN $USERS u ON u.$USERID = ?
      LEFT JOIN $DISCOUNT_GROUPS g ON u.$GROUP_ID = g.$GROUP_ID

      $whereString
      ORDER BY $orderBy
      LIMIT ? OFFSET ?
      ''',
        [...args, limit, offset],
      );

      return result.map((e) => ProductModel.fromMap(e)).toList();
    } catch (e) {
      log("Error (getFilteredProducts): ${e.toString()}");
      return [];
    }
  }

  Future<int> getTotalPages({
    required int userId,
    required int pageSize,
    String? searchQuery,
    int? categoryId,
  }) async {
    final totalItems = await getFilteredProductCount(
      userId: userId,
      searchQuery: searchQuery,
      categoryId: categoryId,
    );
    return (totalItems / pageSize).ceil();
  }

  Future<List<ProductModel>> productSearch(String query, int userId) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        '''
      SELECT 
        p.$PRODUCT_ID,
        p.$PRODUCT_NAME,
        p.$DESCRIPTION,
        p.$PRICE,
        p.$MARKET_RATE,
        p.$STOCK_QTY,
        p.$SOLD_QTY,
        p.$PRODUCT_IMAGE,
        p.$CATEGORY_ID,
        p.$INSERT_DATE,
        c.$CATEGORY_NAME,

        CASE WHEN f.$PRODUCT_ID IS NOT NULL THEN 1 ELSE 0 END AS is_favorite,

        g.$DISCOUNT_PERCENTAGE,
        ROUND(
          CASE 
            WHEN g.$DISCOUNT_PERCENTAGE IS NOT NULL 
            THEN p.$PRICE - (p.$PRICE * g.$DISCOUNT_PERCENTAGE / 100)
            ELSE p.$PRICE 
          END, 2
        ) AS discounted_price

      FROM $PRODUCTS p
      JOIN $CATEGORIES c ON p.$CATEGORY_ID = c.$CATEGORY_ID

      LEFT JOIN $FAVORITES f 
        ON p.$PRODUCT_ID = f.$PRODUCT_ID AND f.$USERID = ?

      LEFT JOIN $USERS u ON u.$USERID = ?
      LEFT JOIN $DISCOUNT_GROUPS g ON u.$GROUP_ID = g.$GROUP_ID

      WHERE LOWER(p.$PRODUCT_NAME) LIKE ?

      ORDER BY p.$PRODUCT_ID DESC
    ''',
        [userId, userId, '%${query.toLowerCase()}%'],
      );

      return result.map((e) => ProductModel.fromMap(e)).toList();
    } catch (e) {
      log("Error (productSearch): ${e.toString()}");
      return [];
    }
  }

  // fetch product by cat id
  Future<List<ProductModel>> getAllUserProductsByCatID(
    int catID,
    int userID,
  ) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        '''
      SELECT 
        p.$PRODUCT_ID,
        p.$PRODUCT_NAME,
        p.$DESCRIPTION,
        p.$PRICE,
        p.$MARKET_RATE,
        p.$STOCK_QTY,p.$SOLD_QTY,
        p.$PRODUCT_IMAGE,
        p.$CATEGORY_ID,
        p.$INSERT_DATE,
        c.$CATEGORY_NAME,
        CASE WHEN f.$PRODUCT_ID IS NOT NULL THEN 1 ELSE 0 END AS is_favorite,
        dg.$DISCOUNT_PERCENTAGE,
        CASE 
          WHEN dg.$DISCOUNT_PERCENTAGE IS NOT NULL 
          THEN ROUND(p.$PRICE - (p.$PRICE * dg.$DISCOUNT_PERCENTAGE / 100), 2) 
          ELSE p.$PRICE 
        END AS discounted_price
      FROM $PRODUCTS p
      JOIN $CATEGORIES c ON p.$CATEGORY_ID = c.$CATEGORY_ID
      LEFT JOIN $FAVORITES f ON p.$PRODUCT_ID = f.$PRODUCT_ID AND f.$USERID = ?
      LEFT JOIN $USERS u ON u.$USERID = ?
      LEFT JOIN $DISCOUNT_GROUPS dg ON dg.$GROUP_ID = u.$GROUP_ID
      WHERE p.$CATEGORY_ID = ?
      ORDER BY p.$PRODUCT_ID DESC
    ''',
        [userID, userID, catID],
      );

      log("Products with category + discount: $result");

      return result.map((e) => ProductModel.fromMap(e)).toList();
    } catch (e) {
      log("Error (getAllUserProductsByCatID): ${e.toString()}");
      return [];
    }
  }

  //// filter by price high,low
  Future<List<ProductModel>> getAllUserProductsFilterByPrice(
    int userID, {
    required String order,
  }) async {
    try {
      final db = await database;
      final safeOrder = (order.toUpperCase() == 'DESC') ? 'DESC' : 'ASC';

      final result = await db.rawQuery(
        '''
      SELECT 
        p.$PRODUCT_ID,
        p.$PRODUCT_NAME,
        p.$DESCRIPTION,
        p.$PRICE,
        p.$MARKET_RATE,
        p.$STOCK_QTY,p.$SOLD_QTY,
        p.$PRODUCT_IMAGE,
        p.$CATEGORY_ID,
        p.$INSERT_DATE,
        c.$CATEGORY_NAME,
        CASE WHEN f.$PRODUCT_ID IS NOT NULL THEN 1 ELSE 0 END AS is_favorite,
        g.$DISCOUNT_PERCENTAGE,
        ROUND(
          CASE 
            WHEN g.$DISCOUNT_PERCENTAGE IS NOT NULL 
            THEN p.$PRICE - (p.$PRICE * g.$DISCOUNT_PERCENTAGE / 100)
            ELSE p.$PRICE 
          END, 2
        ) AS discounted_price
      FROM $PRODUCTS p
      JOIN $CATEGORIES c ON p.$CATEGORY_ID = c.$CATEGORY_ID

      LEFT JOIN $FAVORITES f 
        ON p.$PRODUCT_ID = f.$PRODUCT_ID AND f.$USERID = ?

      LEFT JOIN $USERS u ON u.$USERID = ?
      LEFT JOIN $DISCOUNT_GROUPS g ON u.$GROUP_ID = g.$GROUP_ID

      ORDER BY discounted_price $safeOrder
    ''',
        [userID, userID],
      );

      log("Products with discount: $result");

      return result.map((e) => ProductModel.fromMap(e)).toList();
    } catch (e) {
      log("Error (getAllUserProductsFilterByPrice): ${e.toString()}");
      return [];
    }
  }

  // filter by alphabetical order
  Future<List<ProductModel>> getAllUserProductsFilterByName(
    int userID, {
    required String order,
  }) async {
    try {
      final db = await database;
      final safeOrder = (order.toUpperCase() == 'DESC') ? 'DESC' : 'ASC';

      final result = await db.rawQuery(
        '''
      SELECT 
        p.$PRODUCT_ID,
        p.$PRODUCT_NAME,
        p.$DESCRIPTION,
        p.$PRICE,
        p.$MARKET_RATE,
        p.$STOCK_QTY,p.$SOLD_QTY,
        p.$PRODUCT_IMAGE,
        p.$CATEGORY_ID,
        p.$INSERT_DATE,
        c.$CATEGORY_NAME,
        CASE WHEN f.$PRODUCT_ID IS NOT NULL THEN 1 ELSE 0 END AS is_favorite,
        g.$DISCOUNT_PERCENTAGE,
        ROUND(
          CASE 
            WHEN g.$DISCOUNT_PERCENTAGE IS NOT NULL 
            THEN p.$PRICE - (p.$PRICE * g.$DISCOUNT_PERCENTAGE / 100)
            ELSE p.$PRICE 
          END, 2
        ) AS discounted_price
      FROM $PRODUCTS p
      JOIN $CATEGORIES c ON p.$CATEGORY_ID = c.$CATEGORY_ID

      LEFT JOIN $FAVORITES f 
        ON p.$PRODUCT_ID = f.$PRODUCT_ID AND f.$USERID = ?

      LEFT JOIN $USERS u ON u.$USERID = ?
      LEFT JOIN $DISCOUNT_GROUPS g ON u.$GROUP_ID = g.$GROUP_ID

      ORDER BY p.$PRODUCT_NAME $safeOrder
    ''',
        [userID, userID],
      );

      log("Products with discount: $result");

      return result.map((e) => ProductModel.fromMap(e)).toList();
    } catch (e) {
      log("Error (getAllUserProductsFilterByName): ${e.toString()}");
      return [];
    }
  }

  // filter by most popular
  Future<List<ProductModel>> getAllUserProductsFilterByPopular(
    int userID,
  ) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        '''
      SELECT
        p.$PRODUCT_ID,
        p.$PRODUCT_NAME,
        p.$DESCRIPTION,
        p.$PRICE,
        p.$MARKET_RATE,
        p.$STOCK_QTY,p.$SOLD_QTY,
        p.$PRODUCT_IMAGE,
        p.$CATEGORY_ID,
        p.$INSERT_DATE,
        c.$CATEGORY_NAME,
        CASE WHEN f.$PRODUCT_ID IS NOT NULL THEN 1 ELSE 0 END AS is_favorite,
        g.$DISCOUNT_PERCENTAGE,
        ROUND(
          CASE
            WHEN g.$DISCOUNT_PERCENTAGE IS NOT NULL
            THEN p.$PRICE - (p.$PRICE * g.$DISCOUNT_PERCENTAGE / 100)
            ELSE p.$PRICE
          END, 2
        ) AS discounted_price
      FROM $PRODUCTS p
      JOIN $CATEGORIES c ON p.$CATEGORY_ID = c.$CATEGORY_ID

      LEFT JOIN $FAVORITES f
        ON p.$PRODUCT_ID = f.$PRODUCT_ID AND f.$USERID = ?

      LEFT JOIN $USERS u ON u.$USERID = ?
      LEFT JOIN $DISCOUNT_GROUPS g ON u.$GROUP_ID = g.$GROUP_ID

      ORDER BY p.$SOLD_QTY DESC
    ''',
        [userID, userID],
      );

      log("Products with discount: $result");

      return result.map((e) => ProductModel.fromMap(e)).toList();
    } catch (e) {
      log("Error (getAllUserProductsFilterByPrice): ${e.toString()}");
      return [];
    }
  }

  /////////////// Favorites //////////////
  // add to favorites
  Future<int?> insertFavorite({required productID, required userID}) async {
    try {
      var db = await database;
      return await db.insert(FAVORITES, {
        PRODUCT_ID: productID,
        USERID: userID,
      });
    } catch (e) {
      log("error(insertFavorite) :::: --> ${e.toString()}");
      return null;
    }
  }

  // delete to favorites
  Future<int?> removeFromFavorites(int productId, int userId) async {
    try {
      final db = await database;
      return await db.delete(
        FAVORITES,
        where: '$PRODUCT_ID = ? AND $USERID = ?',
        whereArgs: [productId, userId],
      );
    } catch (e) {
      log("error (removeFromFavorites) : : : ${e.toString()}");
      return null;
    }
  }

  // fetch product details
  Future<ProductModel?> getProductByIDForDetail(
    int productID,
    int userID,
  ) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        '''
      SELECT 
        p.$PRODUCT_ID,
        p.$PRODUCT_NAME,
        p.$DESCRIPTION,
        p.$PRICE,
        p.$MARKET_RATE,
        p.$STOCK_QTY,p.$SOLD_QTY,
        p.$PRODUCT_IMAGE,
        p.$CATEGORY_ID,
        p.$INSERT_DATE,
        c.$CATEGORY_NAME,
        CASE 
          WHEN f.$PRODUCT_ID IS NOT NULL THEN 1 
          ELSE 0 
        END AS is_favorite,
        dg.$DISCOUNT_PERCENTAGE,
        CASE 
          WHEN dg.$DISCOUNT_PERCENTAGE IS NOT NULL 
          THEN ROUND(p.$PRICE - (p.$PRICE * dg.$DISCOUNT_PERCENTAGE / 100), 2)
          ELSE p.$PRICE 
        END AS discounted_price
      FROM $PRODUCTS p
      JOIN $CATEGORIES c ON p.$CATEGORY_ID = c.$CATEGORY_ID
      LEFT JOIN $FAVORITES f 
        ON p.$PRODUCT_ID = f.$PRODUCT_ID AND f.$USERID = ?
      LEFT JOIN $USERS u ON u.$USERID = ?
      LEFT JOIN $DISCOUNT_GROUPS dg ON dg.$GROUP_ID = u.$GROUP_ID
      WHERE p.$PRODUCT_ID = ?
    ''',
        [userID, userID, productID],
      );

      if (result.isNotEmpty) {
        return ProductModel.fromMap(result.first);
      } else {
        return null;
      }
    } catch (e) {
      log("Error in getProductByIDForDetail: $e");
      return null;
    }
  }

  // total fav pages
  Future<int> getTotalFavoritePages({
    required int userId,
    required int pageSize,
  }) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
    SELECT COUNT(*) as totalCount
    FROM $FAVORITES f
    JOIN $PRODUCTS p ON f.$PRODUCT_ID = p.$PRODUCT_ID
    WHERE f.$USERID = ?
    ''',
      [userId],
    );

    final totalCount = Sqflite.firstIntValue(result) ?? 0;

    return (totalCount / pageSize).ceil();
  }

  // get all favorite for user //
  Future<List<ProductModel>> getAllFavoriteProducts(
    int userId, {
    int limit = 10,
    offset = 0,
  }) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        '''
      SELECT 
        p.$PRODUCT_ID,
        p.$PRODUCT_NAME,
        p.$PRODUCT_IMAGE,
        p.$DESCRIPTION,
        p.$PRICE,
        p.$MARKET_RATE,
        p.$STOCK_QTY,p.$SOLD_QTY,
        p.$INSERT_DATE,
        p.$CATEGORY_ID,
        c.$CATEGORY_NAME,
        1 AS $IS_FAVORITE,  -- Because only favorite products
        dg.$DISCOUNT_PERCENTAGE,
        CASE 
          WHEN dg.$DISCOUNT_PERCENTAGE IS NOT NULL 
          THEN ROUND(p.$PRICE - (p.$PRICE * dg.$DISCOUNT_PERCENTAGE / 100), 2)
          ELSE p.$PRICE
          
        END AS $DISCOUNTED_PRICE
      FROM $FAVORITES f
      JOIN $PRODUCTS p ON f.$PRODUCT_ID = p.$PRODUCT_ID
      LEFT JOIN $CATEGORIES c ON p.$CATEGORY_ID = c.$CATEGORY_ID
      LEFT JOIN $USERS u ON u.$USERID = f.$USERID
      LEFT JOIN $DISCOUNT_GROUPS dg ON dg.$GROUP_ID = u.$GROUP_ID
      WHERE f.$USERID = ?
      ORDER BY f.$FAVORITE_ID DESC
      LIMIT ? OFFSET ?
    ''',
        [userId, limit, offset],
      );

      return result.map((e) => ProductModel.fromMap(e)).toList();
    } catch (e) {
      log('Error fetching favorite products: $e');
      return [];
    }
  }

  //////////////////////// cart operations /////////////////////
  Future<int> insertIntoCart(int userId, int productId, int quantity) async {
    final db = await database;

    try {
      // Check if already exists
      final existing = await db.query(
        CART,
        where: '$USERID = ? AND $PRODUCT_ID = ?',
        whereArgs: [userId, productId],
      );

      if (existing.isNotEmpty) {
        // Update quantity
        return await db.update(
          CART,
          {PRODUCT_QTY: (existing.first[PRODUCT_QTY] as int) + quantity},
          where: '$CART_ID = ?',
          whereArgs: [existing.first[CART_ID]],
        );
      } else {
        // Insert new item

        return await db.insert(CART, {
          USERID: userId,
          PRODUCT_ID: productId,
          PRODUCT_QTY: quantity,
        });
      }
    } catch (e) {
      log("Error inserting into cart: $e");
      return 0;
    }
  }

  ///////////// Remove from Cart /////////////
  Future<int?> deleteFromCart(int cartID) async {
    try {
      var db = await database;
      return await db.delete(CART, where: "$CART_ID =?", whereArgs: [cartID]);
    } catch (e) {
      log("error (deleteFromCart) : : : : --> ${e.toString()}");
      return null;
    }
  }

  // get all cart items
  Future<List<CartItemModel>> getCartItemsWithDiscountByUserID(
    int userID,
  ) async {
    try {
      final db = await database;

      final result = await db.rawQuery(
        '''
      SELECT 
        c.$CART_ID,
        c.$PRODUCT_QTY,
        p.$PRODUCT_ID,
        p.$PRODUCT_NAME,
        p.$PRODUCT_IMAGE,
        p.$PRICE AS $ORIGINAL_PRICE,
        p.$DESCRIPTION,
        p.$MARKET_RATE,
        dg.$DISCOUNT_PERCENTAGE,
        CASE 
          WHEN dg.$DISCOUNT_PERCENTAGE IS NOT NULL 
          THEN ROUND(p.$PRICE - (p.$PRICE * dg.$DISCOUNT_PERCENTAGE / 100), 2)
          ELSE p.$PRICE 
        END AS discounted_price,
        CASE 
          WHEN dg.$DISCOUNT_PERCENTAGE IS NOT NULL 
          THEN ROUND((p.$PRICE - (p.$PRICE * dg.$DISCOUNT_PERCENTAGE / 100)) * c.$PRODUCT_QTY, 2)
          ELSE p.$PRICE * c.$PRODUCT_QTY 
        END AS total_price
      FROM $CART c
      JOIN $PRODUCTS p ON c.$PRODUCT_ID = p.$PRODUCT_ID
      JOIN $USERS u ON c.$USERID = u.$USERID
      LEFT JOIN $DISCOUNT_GROUPS dg ON u.$GROUP_ID = dg.$GROUP_ID
      WHERE c.$USERID = ?
      ORDER BY c.$CART_ID DESC
    ''',
        [userID],
      );
      return result.map((e) => CartItemModel.fromMap(e)).toList();
    } catch (e) {
      log("Error getting cart with discount: $e");
      return [];
    }
  }

  // decrease quantity
  Future<int?> decreaseQuantity(int cartID, int qty) async {
    try {
      var db = await database;

      return await db.update(
        CART,
        {'product_qty': qty},
        where: "$CART_ID =?",
        whereArgs: [cartID],
      );
    } catch (e) {
      log("error (decreaseQuantity) : : : --> ${e.toString()}");
      return null;
    }
  }

  /////////// Address //////////////
  Future<int?> insertAddress(AddressModel address) async {
    try {
      final db = await database;

      // Count how many addresses the user already has
      final result = await db.rawQuery(
        'SELECT COUNT(*) as total FROM $ADDRESSES WHERE $USERID = ?',
        [address.userId],
      );

      final count = Sqflite.firstIntValue(result) ?? 0;
      int isDefault = address.isDefault ? 1 : 0;

      // If it's the first address, set as default
      if (count == 0) {
        isDefault = 1;
      } else if (isDefault == 1) {
        // If user manually sets this as default, reset others to 0
        await db.update(
          ADDRESSES,
          {IS_DEFAULT: 0},
          where: '$USERID = ?',
          whereArgs: [address.userId],
        );
      }

      // Prepare the map with updated default flag
      final data = address.toMap();
      data[IS_DEFAULT] = isDefault;

      return await db.insert(ADDRESSES, data);
    } catch (e) {
      log('Insert address error: $e');
      return null;
    }
  }

  /////// update address //////
  Future<int?> updateAddress(
    AddressModel address, {
    required int addressID,
  }) async {
    try {
      var db = await database;
      return await db.update(
        ADDRESSES,
        address.toMap(),
        where: "$ADDRESS_ID = ?",
        whereArgs: [addressID],
      );
    } catch (e) {
      log("error : : : : : ${e.toString()}");
      return null;
    }
  }

  // delete address
  Future<int?> deleteAddress({
    required int addressID,
    required int userID,
  }) async {
    try {
      var db = await database;

      // Step 1: Check if this address is default
      final address = await db.query(
        ADDRESSES,
        where: "$ADDRESS_ID = ?",
        whereArgs: [addressID],
      );

      bool wasDefault = address.isNotEmpty && address.first[IS_DEFAULT] == 1;

      // Step 2: Delete the address
      int deleted = await db.delete(
        ADDRESSES,
        where: "$ADDRESS_ID = ?",
        whereArgs: [addressID],
      );

      // Step 3: If it was default, assign another address as default
      if (wasDefault) {
        final nextAddress = await db.query(
          ADDRESSES,
          where: "$USERID = ?",
          whereArgs: [userID],
          orderBy: "$ADDRESS_ID DESC",
          limit: 1,
        );

        if (nextAddress.isNotEmpty) {
          int newDefaultID = int.parse(
            nextAddress.first[ADDRESS_ID].toString(),
          );
          await db.update(
            ADDRESSES,
            {IS_DEFAULT: 1},
            where: "$ADDRESS_ID = ?",
            whereArgs: [newDefaultID],
          );
        }
      }

      return deleted;
    } catch (e) {
      return null;
    }
  }

  // fetch all address
  Future<List<AddressModel>> getAllAddress({required int userID}) async {
    try {
      var db = await database;
      var result = await db.query(
        ADDRESSES,
        where: "$USERID = ?",
        whereArgs: [userID],
      );
      if (result.isNotEmpty) {
        return result.map((e) => AddressModel.fromMap(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      log("error (getAllAddress) :: : :: : ${e.toString()}");
      return [];
    }
  }

  Future<void> setAddressAsDefault(int userId, int selectedAddressId) async {
    final db = await database;

    await db.transaction((txn) async {
      // Step 1: Set all addresses for user to non-default
      await txn.update(
        ADDRESSES,
        {'is_default': 0},
        where: '$USERID = ?',
        whereArgs: [userId],
      );

      // Step 2: Set selected address to default
      await txn.update(
        ADDRESSES,
        {IS_DEFAULT: 1},
        where: '$ADDRESS_ID = ? AND $USERID = ?',
        whereArgs: [selectedAddressId, userId],
      );
    });
  }

  // get address by id
  Future<AddressModel?> getAddressByID(int addressID) async {
    try {
      var db = await database;
      var result = await db.rawQuery(
        '''
      SELECT * FROM $ADDRESSES WHERE $ADDRESS_ID=?
       ''',
        [addressID],
      );
      return AddressModel.fromMap(result.first);
    } catch (e) {
      log("error (getAddressByID) : : : ${e.toString()}");
      return null;
    }
  }

  // get default address for current user
  Future<AddressModel?> getDefaultAddress(int userID) async {
    try {
      var db = await database;
      var result = await db.query(
        ADDRESSES,
        where: "$USERID = ? AND $IS_DEFAULT =1",
        whereArgs: [userID],
      );
      return AddressModel.fromMap(result.first);
    } catch (e) {
      log("error (getDefaultAddress) : : : : ${e.toString()}");

      return null;
    }
  }

  // Orders
  Future<int?> insertOrder(OrderModel order) async {
    try {
      var db = await database;
      return await db.insert(ORDERS, order.toMap());
    } catch (e) {
      log("error (insertOrder) : : : : ${e.toString()}");
      return null;
    }
  }

  // fetch product stock by product id
  Future<bool> isInStock(int productID, int qty) async {
    try {
      var db = await database;
      var result = await db.rawQuery(
        '''
        SELECT $STOCK_QTY FROM $PRODUCTS WHERE $PRODUCT_ID =?
      ''',
        [productID],
      );
      if (result.isNotEmpty) {
        return int.parse(result.first[STOCK_QTY].toString()) > 0 &&
            qty <= int.parse(result.first[STOCK_QTY].toString());
      } else {
        return false;
      }
    } catch (e) {
      log("error (isInStock) : : : ${e.toString()}");
      return false;
    }
  }

  // fetch available stock
  Future<Map<String, dynamic>> fetchStock(int productID) async {
    try {
      var db = await database;
      var result = await db.rawQuery(
        '''
        SELECT $STOCK_QTY,$SOLD_QTY FROM $PRODUCTS WHERE $PRODUCT_ID =?
      ''',
        [productID],
      );
      if (result.isNotEmpty) {
        return {
          STOCK_QTY: result.first[STOCK_QTY],
          SOLD_QTY: result.first[SOLD_QTY],

        };
      } else {
        return {};
      }
    } catch (e) {
      log("error (fetchStock) : : : ${e.toString()}");
      return {};
    }
  }

  //check stock in inventory
  Future<List<InventoryItemModel>> fetchStockFromInventory(int productID) async {
    try {
      var db = await database;
      var result = await db.rawQuery(
        '''
        SELECT * FROM $INVENTORY_ITEMS WHERE $PRODUCT_ID =?
      ''',
        [productID],
      );
      if (result.isNotEmpty) {
        return result.map((e) => InventoryItemModel.fromMap(e),).toList();
      } else {
        return [];
      }
    } catch (e) {
      log("error (fetchStockFromInventory) : : : ${e.toString()}");
      return [];
    }
  }

  // clear cart after placing order
  Future<void> clearUserCart(int userID) async {
    try {
      var db = await database;
      await db.delete(CART, where: "$USERID=?", whereArgs: [userID]);
    } catch (e) {
      log("error (clearUserCart) : : : : : : ${e.toString()}");
    }
  }

  // deduct stock after place order
  // Future<int?> deductStock({required productID, required int qty}) async {
  //   try {
  //     var db = await database;
  //     final stock = await fetchStock(productID);
  //     if (stock.isNotEmpty) {
  //       var result = await db.update(
  //         PRODUCTS,
  //         {STOCK_QTY: stock[STOCK_QTY] - qty, SOLD_QTY: stock[SOLD_QTY] + qty},
  //         where: "$PRODUCT_ID=?",
  //         whereArgs: [productID],
  //       );
  //       return result;
  //     }
  //   } catch (e) {
  //     log("error (deductStock) : : : --> ${e.toString()}");
  //     return null;
  //   }
  //   return null;
  // }


  // deduct stock after place order
  Future<int?> deductStock({required int productID, required int qty}) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        // Get current product info
        final productResult = await txn.query(
          PRODUCTS,
          columns: [SERIAL_NUMBER, STOCK_QTY, SOLD_QTY],
          where: '$PRODUCT_ID = ?',
          whereArgs: [productID],
        );
        if (productResult.isEmpty) {
          throw Exception('Product not found');
        }
        final product = productResult.first;
        String? currentSr = product[SERIAL_NUMBER] as String?;
        int currentSoldQty = product[SOLD_QTY] as int;

        int remaining = qty;
        String activeSr = currentSr ?? '';

        while (remaining > 0) {
          // Get current inventory item for active SR
          final invResult = await txn.query(
            INVENTORY_ITEMS,
            where: '$SERIAL_NUMBER = ? AND $PRODUCT_ID = ?',
            whereArgs: [activeSr, productID],
            limit: 1,
          );

          Map<String, dynamic>? currentInv;
          if (invResult.isNotEmpty) {
            currentInv = invResult.first;
            int avail = currentInv[INVENTORY_QUANTITY] as int;
            if (avail <= 0) {
              currentInv = null; // Treat as no stock
            }
          }

          if (currentInv == null) {
            // No stock in current SR, find next available
            final nextInvResult = await txn.rawQuery('''
              SELECT * FROM $INVENTORY_ITEMS 
              WHERE $PRODUCT_ID = ? AND $INVENTORY_QUANTITY > 0 
              AND $SERIAL_NUMBER != ? 
              ORDER BY $INVENTORY_ITEM_ID ASC 
              LIMIT 1
            ''', [productID, activeSr]);

            if (nextInvResult.isEmpty) {
              // No more available inventory
              break;
            }

            currentInv = nextInvResult.first;
            activeSr = currentInv[SERIAL_NUMBER] as String;

            // Assign new SR to product
            await txn.update(
              PRODUCTS,
              {SERIAL_NUMBER: activeSr},
              where: '$PRODUCT_ID = ?',
              whereArgs: [productID],
            );
          }

          // Deduct from current inventory
          int avail = currentInv[INVENTORY_QUANTITY] as int;
          int deductHere = math.min(avail, remaining);
          int newInvQty = avail - deductHere;

          await txn.update(
            INVENTORY_ITEMS,
            {INVENTORY_QUANTITY: newInvQty},
            where: '$INVENTORY_ITEM_ID = ?',
            whereArgs: [currentInv[INVENTORY_ITEM_ID]],
          );

          remaining -= deductHere;

          // If depleted, optionally remove if qty == 0 (but user said no remove sr, but this is inventory, not product sr)
          if (newInvQty == 0) {
            // Leave it as 0, or delete if preferred
            // await txn.delete(INVENTORY_ITEMS, where: '$INVENTORY_ITEM_ID = ?', whereArgs: [currentInv[INVENTORY_ITEM_ID]]);
          }
        }

        // Calculate deducted amount
        int deducted = qty - remaining;

        if (deducted > 0) {
          // Update product totals
          final newSoldQty = currentSoldQty + deducted;
          final newStockQty = await _getTotalStockFromInventory(txn, productID);

          await txn.update(
            PRODUCTS,
            {
              SOLD_QTY: newSoldQty,
              STOCK_QTY: newStockQty,
            },
            where: '$PRODUCT_ID = ?',
            whereArgs: [productID],
          );
        }
      });

      // Return 1 for success if deducted >0, else 0
      final stock = await fetchStock(productID);
      return (stock[STOCK_QTY] as int) < (stock[STOCK_QTY] + qty) ? 1 : 0;
    } catch (e) {
      log("error (deductStock) : : : --> ${e.toString()}");
      return null;
    }
  }

  // Helper method to get total stock from inventory
  Future<int> _getTotalStockFromInventory(Transaction txn, int productID) async {
    final result = await txn.rawQuery('''
      SELECT SUM($INVENTORY_QUANTITY) as total 
      FROM $INVENTORY_ITEMS 
      WHERE $PRODUCT_ID = ? AND $INVENTORY_QUANTITY > 0
    ''', [productID]);
    return Sqflite.firstIntValue(result) ?? 0;
  }


  // insert order items
  Future<int?> insertOrderItem(OrderItemModel orderItem) async {
    try {
      var db = await database;
      return await db.insert(ORDER_ITEMS, orderItem.toMap());
    } catch (e) {
      log("error (insertOrderItem) : : : : : ${e.toString()}");
      return null;
    }
  }

  // fetch order items for order
  Future<List<OrderItemModel>> getOrderItemsByOrderID(int orderID) async {
    try {
      var db = await database;
      var result = await db.query(
        ORDER_ITEMS,
        where: "$ORDERID =?",
        whereArgs: [orderID],
      );
      return result.map((item) => OrderItemModel.fromMap(item)).toList();
    } catch (e) {
      log("error (getOrderItemsByOrderID) : : : : : ${e.toString()}");
      return [];
    }
  }

  // get orders for user
  Future<List<OrderModel>> getUsersOrdersByStatus(
    int userID,
    String status, {
    int limit = 20,
    offset = 0,
  }) async {
    try {
      var db = await database;
      var result = await db.query(
        ORDERS,
        where: "$USERID = ? AND $ORDER_STATUS =?",
        whereArgs: [userID, status],
        limit: limit,
        offset: offset,
      );
      return result.map((order) => OrderModel.fromMap(order)).toList();
    } catch (e) {
      log("error (getOrdersByStatus) : : : : : ${e.toString()}");
      return [];
    }
  }

  // get total page counts
  Future<int> getTotalPagesForUserOrdersByStatus(
    int userID,
    String status, {
    int limit = 20,
  }) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $ORDERS WHERE $USERID = ? AND $ORDER_STATUS = ?',
        [userID, status],
      );

      final count = Sqflite.firstIntValue(result) ?? 0;
      return (count / limit).ceil();
    } catch (e) {
      log(
        "error (getTotalPagesForUserOrdersByStatus) ::::::--> ${e.toString()}",
      );
      return 0;
    }
  }

  // get orders for ADMIN
  Future<List<OrderModel>> getOrdersByStatus(
    String status, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var db = await database;
      var result = await db.query(
        ORDERS,
        where: "$ORDER_STATUS = ?",
        whereArgs: [status],
        limit: limit,
        offset: offset,
      );
      return result.map((order) => OrderModel.fromMap(order)).toList();
    } catch (e) {
      log("error (getOrdersByStatus) : : : : : ${e.toString()}");
      return [];
    }
  }

  // get total page counts
  Future<int> getTotalPagesForOrdersByStatus(
    String status, {
    int limit = 20,
  }) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $ORDERS WHERE $ORDER_STATUS = ?',
        [status],
      );

      final count = Sqflite.firstIntValue(result) ?? 0;
      return (count / limit).ceil();
    } catch (e) {
      log("error (getTotalPagesForOrdersByStatus) ::::::--> ${e.toString()}");
      return 0;
    }
  }

  // fetch order by id
  Future<OrderModel?> getOrderByID(int orderID) async {
    try {
      var db = await database;
      var result = await db.query(
        ORDERS,
        where: "$ORDERID = ?",
        whereArgs: [orderID],
      );
      return OrderModel.fromMap(result.first);
    } catch (e) {
      log("error (getOrderByID) : : : : ${e.toString()}");
      return null;
    }
  }

  // dashboard map data
  Future<List<OrderModel>> getOrderLocations({String? statusFilter}) async {
    try {
      final db = await database;
      final whereClause = statusFilter != null ? 'WHERE $ORDER_STATUS = ?' : '';
      final whereArgs = statusFilter != null ? [statusFilter] : [];
      final result = await db.rawQuery('''
      SELECT *
      FROM $ORDERS
      $whereClause
      ORDER BY $ORDERID DESC
      ''', whereArgs);

      return result.map((order) => OrderModel.fromMap(order)).toList();
    } catch (e) {
      log("error (getOrderLocations) : : : : ${e.toString()}");
      return [];
    }
  }

  Future<List<SupplierModel>> getSuppliers({
    int isDeleted = 0,
    int limit = 20,
    int offset = 0,
    String? searchQuery,
  }) async {
    try {
      final db = await database;

      // Base WHERE condition
      String whereClause = "$IS_DELETED = ?";
      List<dynamic> whereArgs = [isDeleted];

      // Add search filter if query is provided
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        whereClause += " AND $SUPPLIER_NAME LIKE ?";
        whereArgs.add('%$searchQuery%');
      }

      final result = await db.query(
        SUPPLIERS,
        where: whereClause,
        whereArgs: whereArgs,
        limit: limit,
        offset: offset,
        orderBy: "$SUPPLIER_NAME ASC", // optional
      );

      return result.map((supplier) => SupplierModel.fromMap(supplier)).toList();
    } catch (e) {
      log("error (fetchSuppliers): ${e.toString()}");
      return [];
    }
  }

  // insert new supplier
  Future<int> insertSupplier(SupplierModel newSupplier) async {
    try {
      var db = await database;
      return await db.insert(SUPPLIERS, newSupplier.toMap());
    } catch (e) {
      log("error (insertSupplier) : : : : ${e.toString()}");
      return 0;
    }
  }

  // update supplier
  Future<int?> updateSupplier(int supplierID, SupplierModel supplier) async {
    try {
      var db = await database;
      return await db.update(
        SUPPLIERS,
        supplier.toMap(),
        where: "$SUPPLIER_ID = ?",
        whereArgs: [supplierID],
      );
    } catch (e) {
      log("error (updateSupplier) : : : : ${e.toString()}");
      return null;
    }
  }

  // create P O
  Future<int> insertPO(PurchaseOrderModel po) async {
    try {
      final db = await database;
      return await db.insert(PURCHASE_ORDERS, po.toMap());
    } catch (e) {
      log("error (insertPO) : ::: : error is ${e.toString()}");
      return 0;
    }
  }

  // update P O
  Future<int> updatePO(PurchaseOrderModel po) async {
    try {
      final db = await database;
      return await db.update(
        PURCHASE_ORDERS,
        po.toMap(),
        where: "$PURCHASE_ORDER_ID = ?",
        whereArgs: [po.id],
      );
    } catch (e) {
      log("error (updatePO) : ::: : error is ${e.toString()}");
      return 0;
    }
  }

  // add purchase order items
  Future<int> insertPOrderItem(PurchaseOrderItemModel poItem) async {
    try {
      final db = await database;
      return await db.insert(PURCHASE_ORDER_ITEMS, poItem.toMap());
    } catch (e) {
      log("error (insertOrderItem) :::: ::::::: ::::: ${e.toString()}");
      return 0;
    }
  }

  // fetch PO items by PO id
  Future<List<PurchaseOrderItemModel>> getPOItemsByPOID(int poID) async {
    try {
      final db = await database;
      // JOIN purchase_order_items with products
      final result = await db.rawQuery(
        '''
      SELECT i.*, p.$PRODUCT_NAME 
      FROM $PURCHASE_ORDER_ITEMS i
      INNER JOIN $PRODUCTS p 
        ON i.$PRODUCT_ID = p.$PRODUCT_ID
      WHERE i.$PURCHASE_ORDER_ID = ? AND $IS_RECEIVED =?
    ''',
        [poID,0],
      );
      return result
          .map((poItem) => PurchaseOrderItemModel.fromMap(poItem))
          .toList();
    } catch (e) {
      log("error (getPOItemsByPOID): ${e.toString()}");
      return [];
    }
  }

  // get all POs
  Future<List<PurchaseOrderModel>> getPOs({
    int? isReceived,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final db = await database;

      final result = await db.rawQuery(
        '''
      SELECT o.*, s.$SUPPLIER_NAME
      FROM $PURCHASE_ORDERS o
      INNER JOIN $SUPPLIERS s 
        ON o.$SUPPLIER_ID = s.$SUPPLIER_ID
      ${isReceived != null ? 'WHERE o.$IS_RECEIVED = ?' : ''}
      ORDER BY o.$PURCHASE_ORDER_ID DESC
      LIMIT ? OFFSET ?
    ''',
        [if (isReceived != null) isReceived, limit, offset],
      );

      return result.map((po) => PurchaseOrderModel.fromMap(po)).toList();
    } catch (e) {
      log('error (getPOs): ${e.toString()}');
      return [];
    }
  }

  // update po item
  Future<int> updatePOItem(PurchaseOrderItemModel poItem) async {
    try {
      final db = await database;
      return await db.update(
        PURCHASE_ORDER_ITEMS,
        poItem.toMap(),
        where: "$PURCHASE_ITEM_ID = ?",
        whereArgs: [poItem.id],
      );
    } catch (e) {
      log("error (updatePOItem) : ::: : error is ${e.toString()}");
      return 0;
    }
  }


  Future<int> updatePOStatus({required int poID,required int isPartial, required int isReceived}) async {
    try {
      final db = await database;
      return await db.update(PURCHASE_ORDERS, {IS_RECEIVED:isReceived,IS_PARTIALLY_RECIEVED:isPartial},where: "$PURCHASE_ORDER_ID = ?",whereArgs: [poID]);
    } catch (e) {
      log("error (updatePOStatus) : ::: : error is ${e.toString()}");
      return 0;
    }
  }


  /// update product selling price and quantity
  Future<int> updateProductStock({required int productID, required double sellingPrice, required int quantity}) async {
    try {
      final db = await database;
      final product = await getProductByID(productID: productID);
      if(product != null) {
      int newQuantity = product[STOCK_QTY] + quantity;
      return await db.update(PRODUCTS, {PRICE:sellingPrice,STOCK_QTY:newQuantity},where: "$PRODUCT_ID = ?",whereArgs: [productID]);
      }
      return 0;
    } catch (e) {
      log("error (updateProductStock) : ::: : error is ${e.toString()}");
      return 0;
    }
  }

  Future<List<ProfitLossData>> getProfitLossReport(
      String startDate,
      String endDate,
      ) async {
    final db = await database;

    final result = await db.rawQuery('''
    WITH ProductCost AS (
      SELECT 
        $PRODUCT_ID,
        AVG($COST_PER_UNIT) AS avg_cost
      FROM $PURCHASE_ORDER_ITEMS
      GROUP BY $PRODUCT_ID
    )
    SELECT 
      DATE(o.$ORDER_DATE) AS date,
      SUM(oi.$ITEM_PRICE * oi.$ITEM_QTY) AS total_sales,
      SUM(pc.avg_cost * oi.$ITEM_QTY) AS total_cost,
      CASE 
        WHEN (SUM(oi.$ITEM_PRICE * oi.$ITEM_QTY) - SUM(pc.avg_cost * oi.$ITEM_QTY)) >= 0 
          THEN (SUM(oi.$ITEM_PRICE * oi.$ITEM_QTY) - SUM(pc.avg_cost * oi.$ITEM_QTY))
        ELSE 0
      END AS profit,
      CASE 
        WHEN (SUM(oi.$ITEM_PRICE * oi.$ITEM_QTY) - SUM(pc.avg_cost * oi.$ITEM_QTY)) < 0 
          THEN ABS(SUM(oi.$ITEM_PRICE * oi.$ITEM_QTY) - SUM(pc.avg_cost * oi.$ITEM_QTY))
        ELSE 0
      END AS loss
    FROM $ORDER_ITEMS oi
    JOIN $ORDERS o ON o.$ORDERID = oi.$ORDERID
    LEFT JOIN ProductCost pc ON pc.$PRODUCT_ID = oi.$PRODUCT_ID
    WHERE DATE(o.$ORDER_DATE) BETWEEN ? AND ?
    GROUP BY DATE(o.$ORDER_DATE)
    ORDER BY DATE(o.$ORDER_DATE)
  ''', [startDate, endDate]);

    return result.map((e) {
      return ProfitLossData(
        DateTime.parse(e['date'] as String),
        double.tryParse(e['profit'].toString()) ?? 0.0,
        double.tryParse(e['loss'].toString()) ?? 0.0,
      );
    }).toList();
  }




  Future<List<ProductModel>> getTop5RevenueProducts() async {
    final db = await database;

    final result = await db.rawQuery('''
    SELECT 
      p.*,
      SUM(oi.$ITEM_PRICE * oi.$ITEM_QTY) AS total_revenue
    FROM $ORDER_ITEMS oi
    JOIN $PRODUCTS p ON p.$PRODUCT_ID = oi.$PRODUCT_ID
    JOIN $ORDERS o ON o.$ORDERID = oi.$ORDERID
    GROUP BY p.$PRODUCT_ID
    ORDER BY total_revenue DESC
    LIMIT 5
  ''');

    return result.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<List<ProductModel>> getTop5LossProducts() async {
    final db = await database;

    final result = await db.rawQuery('''
    SELECT 
      p.*,
      SUM(
        CASE 
          WHEN poi.$COST_PER_UNIT > oi.$ITEM_PRICE 
            THEN (poi.$COST_PER_UNIT - oi.$ITEM_PRICE) * oi.$ITEM_QTY
          ELSE 0 
        END
      ) AS total_loss
    FROM $ORDER_ITEMS oi
    JOIN $ORDERS o ON o.$ORDERID = oi.$ORDERID
    JOIN $PRODUCTS p ON p.$PRODUCT_ID = oi.$PRODUCT_ID
    LEFT JOIN $PURCHASE_ORDER_ITEMS poi 
      ON poi.$PRODUCT_ID = oi.$PRODUCT_ID 
      AND poi.$SERIAL_NUMBER = oi.$SERIAL_NUMBER
    GROUP BY p.$PRODUCT_ID
    HAVING total_loss > 0
    ORDER BY total_loss DESC
    LIMIT 5
  ''');

    return result.map((e) => ProductModel.fromMap(e)).toList();
  }


  // add item to inventory
  Future<int> insertInventory(InventoryItemModel inventory) async {
    try {
      final db = await database;
      return await db.insert(INVENTORY_ITEMS, inventory.toMap());
    } catch (e) {
      log("error (insertInventory) : ::: : error is ${e.toString()}");
      return 0;
    }
  }


}
