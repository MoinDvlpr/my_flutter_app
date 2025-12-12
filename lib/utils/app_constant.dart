// DATABASE
const String MYSTOREDB = "my_storedb.db";
////////// tables //////////
// users
const String USERS = "users";
//columns
const String USERID = "user_id";
const String USERNAME = "user_name";
const String CONTACT = "contact";
const String EMAIL = "email";
const String PASSWORD = "password";
// const String GROUP_ID ="group_id"; fk
const String IS_LOGGED_IN = "is_logged_in";
const String ROLE = "role";

const String LATITUDE = "latitude";
const String LONGITUDE = "longitude";

// products
const String PRODUCTS = "products";
// columns
const String PRODUCT_ID = "product_id";
const String SR_NO = "serial_number";
const String PRODUCT_NAME = "product_name";
const String PRODUCT_IMAGE = "product_image";
const String DESCRIPTION = "description";
const String PRICE = "price";
const String STOCK_QTY = "stock_qty";
const String SOLD_QTY = "sold_qty";
const String INSERT_DATE = "insert_date";
const String IS_FAVORITE = "is_favorite";
const String COST_PRICE = "cost_price";
const String QUANTITY = "quantity";
const String ORIGINAL_PRICE = "original_price";
const String DISCOUNTED_PRICE = "discounted_price";

// CART
const String CART = "cart";
//columns
const String CART_ID = "cart_id";
const String PRODUCT_QTY = "product_qty";
// USERID FK
// Product ID FK
// CATEGORY
const String CATEGORIES = "categories";
// columns
const String CATEGORY_ID = "category_id";
const String CATEGORY_NAME = "category_name";

// DISCOUNT GROUPS
const String DISCOUNT_GROUPS = "discount_groups";
// columns
const String GROUP_ID = "group_id";
const String GROUP_NAME = "group_name";
const String DISCOUNT_PERCENTAGE = "discount_percentage";

// favorites
const String FAVORITES = "favorites";
// columns
const String FAVORITE_ID = "favorite_id";
// productid, user id -- fk

// Address Table
const String ADDRESSES = "addresses";
const String FULL_NAME = "full_name";
const String PHONE = "contact_number";
const String ADDRESS = "address";
const String CITY = "city";
const String STATE = "state";
const String COUNTRY = "country";
const String ZIPCODE = "zipcode";
const String ADDRESS_ID = "address_id";
const String IS_DEFAULT = "is_default";

// Orders
const String ORDERS = "orders";
const String ORDERID = "order_id";
const String ORDER_STATUS = "order_status";
const String ORDER_DATE = "order_date";
const String SHIPPING_ADDRESS = "shipping_address";
const String SERIAL_NUMBERS = "serial_numbers";
// const String CITY = ;
// const String STATE = ;
// const String COUNTRY = ;
// const String ZIPCODE = ;
const String DELIVERY_CHARGE = "delivery_charge";
const String CUSTOMER_NAME = "customer_name";
const String PAYMENT_METHOD = "payment_method";
// Razorpay fields
const String RP_ORDER_ID = "razorpay_order_id";
const String RP_PAYMENT_ID = "razorpay_payment_id";
const String RP_SIGNATURE = "razorpay_signature";
const String TOTAL_QTY = "total_quantity";
const String TOTAL_AMOUNT = "total_amount";
// USERID -> NOT (FK)

// order status names
const String PAID = "Paid";
const String DELIVERED = "Delivered";
const String PROCESSING = "Processing";
const String CANCELLED = "Cancelled";
const String SHIPPED = "Shipped";

// ORDER ITEMS TABLE
// fk == orderID
const String ORDER_ITEMS = "order_items";
const String ITEM_ID = "items_id";
// const String ITEM_ID= "items_id";
const String ITEM_NAME = "item_name";
const String ITEM_IMAGE = "item_image";
const String ITEM_DESCRIPTION = "item_description";
const String ITEM_PRICE = "item_price";
const String ITEM_QTY = "item_quantity";
const String IS_SOLD = "is_sold";
const String IS_READY_FOR_SALE = "is_ready_for_sale";

// NEW TABLE INTRODUCE INVENTORY
const String INVENTORY = "inventory";
const String INVENTORY_ID = "inventory_id";
const String REMAINING = "remaining";
const String PURCHASE_DATE = "purchase_date";
const String PRODUCT_BATCH = "product_batch";

// const String CATEGORY_NAME = "";

// Table: Suppliers
const String SUPPLIERS = 'suppliers';
const String SUPPLIER_ID = 'supplier_id';
const String SUPPLIER_NAME = 'supplier_name';

// Table: Purchase_Orders
const String PURCHASE_ORDERS = 'purchase_orders';
const String PURCHASE_ORDER_ID = 'purchase_order_id';
const String TOTAL_COST = 'total_cost';
const String IS_ORDER_RECEIVED = "is_order_received";
const String IS_PARTIALLY_RECIEVED = "is_partially_received";
// Table: Purchase_Order_Items
const String PURCHASE_ORDER_ITEMS = 'purchase_order_items';
const String PURCHASE_ITEM_ID = 'purchase_item_id';
const String COST_PER_UNIT = 'cost_per_unit';

// Table: Inventory_Items
const String INVENTORY_ITEMS = 'inventory_items';
const String INVENTORY_QUANTITY = 'inventory_quantity';
const String INVENTORY_ITEM_ID = 'inventory_item_id';
const String SERIAL_NUMBER = 'serial_number';
const String SELLING_PRICE = 'selling_price';
const String MARKET_RATE = 'market_rate';
const String IS_DELETED = 'is_deleted';

const String IS_RECEIVED = 'is_received';

// -------------------------------
// CHAT MESSAGES TABLE
// -------------------------------
const String CHAT_MESSAGES = 'chat_messages';

const String CHAT_MSG_ID = 'chat_msg_id';
const String MESSAGE = 'message';
const String IS_USER = 'isUser';
const String TIMESTAMP = 'timestamp';

// -------------------------------
// CHAT METADATA TABLE
// -------------------------------
const String CHAT_METADATA = 'chat_metadata';
const String IS_ACTIVE = 'is_active';
const String CHAT_METADATA_ID = 'chat_metadata_id';
const String LAST_RESET = 'last_reset';
const String CONTENT = 'content';
