import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_flutter_app/widgets/app_snackbars.dart';
import '../buymateservice/ai_service.dart';
import '../dbservice/db_helper.dart';
import '../model/chat_model.dart';
import '../model/product_model.dart';
import '../model/category_model.dart';
import '../utils/app_constant.dart';

class AIController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late GroqAIService aiService;

  RxList<ChatMessage> messages = <ChatMessage>[].obs;
  RxBool isLoading = false.obs;
  RxBool isTyping = false.obs;

  // Store context data
  List<ProductModel> storeProducts = [];
  List<CategoryModel> storeCategories = [];

  @override
  void onInit() {
    super.onInit();
    // Initialize AI service with your API key
    aiService = GroqAIService(apiKey: dotenv.env['GROQ_API_KEY']!);
    initializeChat();
  }

  Future<void> initializeChat() async {
    try {
      // Check if chat should be reset (24h)
      final shouldReset = await DatabaseHelper.instance.shouldResetChat();
      if (shouldReset) {
        await DatabaseHelper.instance.resetChat();
        showResetNotification();
      }

      // Load existing messages
      final loadedMessages = await DatabaseHelper.instance.getAllMessages();
      messages.value = loadedMessages;

      // Load store data for context
      await loadStoreContext();

      // Scroll to bottom after loading
      await Future.delayed(const Duration(milliseconds: 100));
      scrollToBottom();
    } catch (e) {
      AppSnackbars.error('Error', 'Failed to initialize chat: ${e.toString()}');
    }
  }

  final storage = GetStorage();

  Future<void> loadStoreContext() async {
    try {
      // Load products (limit to prevent memory issues)
      final allProducts = await DatabaseHelper.instance.getProducts(
        limit: 100,
        offset: 0,
      );
      storeProducts = allProducts;

      // Load categories
      final allCategories = await DatabaseHelper.instance.getAllCategories(
        userId: storage.read(USERID),
        limit: 50,
        offset: 0,
      );
      storeCategories = allCategories;
    } catch (e) {
      print('Error loading store context: ${e.toString()}');
    }
  }

  void showResetNotification() {
    Get.closeAllSnackbars();
    AppSnackbars.warning('Chat Reset', 'Chat has been reset (24 hours passed)');
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    // Prevent sending while already processing
    if (isLoading.value || isTyping.value) return;

    messageController.clear();

    final userMessage = ChatMessage(
      message: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Save to database
    await DatabaseHelper.instance.insertMessage(userMessage);

    // Add to UI
    messages.add(userMessage);
    isLoading.value = true;

    scrollToBottom();

    try {
      // Build conversation history
      final history = messages
          .where((msg) => msg.chatMsgID != userMessage.chatMsgID)
          .map((e) => e.toGroqFormat())
          .toList();

      String aiResponse = '';
      ChatMessage? aiMessage;

      isTyping.value = true;
      isLoading.value = false;

      // Stream response for typing effect
      await for (var chunk in aiService.sendMessageStream(
        userMessage: text,
        conversationHistory: history,
        storeContext: _getStoreContext(),
      )) {
        aiResponse += chunk;

        if (aiMessage == null) {
          // Create new AI message
          aiMessage = ChatMessage(
            message: aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
          );
          messages.add(aiMessage);
        } else {
          // Update existing message
          final index = messages.length - 1;
          messages[index] = ChatMessage(
            chatMsgID: aiMessage.chatMsgID,
            message: aiResponse,
            isUser: false,
            timestamp: aiMessage.timestamp,
          );
        }

        // Trigger UI update
        messages.refresh();
        scrollToBottom();
      }

      // Save final AI response to database
      if (aiMessage != null && aiResponse.isNotEmpty) {
        await DatabaseHelper.instance.insertMessage(
          ChatMessage(
            message: aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      }

      isTyping.value = false;
    } catch (e) {
      print('Error sending message: ${e.toString()}');

      // Show error message
      final errorMessage = ChatMessage(
        message: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      messages.add(errorMessage);
      await DatabaseHelper.instance.insertMessage(errorMessage);

      isLoading.value = false;
      isTyping.value = false;

      AppSnackbars.error('Error', 'Failed to get AI response');
    }
  }

  String _getStoreContext() {
    // Build dynamic context from actual store data
    final categoryNames = storeCategories
        .map((cat) => cat.categoryName)
        .join(', ');

    // Get some sample products for context
    final sampleProducts = storeProducts
        .take(10)
        .map(
          (p) =>
              '${p.productName} (₹${p.price}${p.discountedPrice != null && p.discountedPrice! < p.price ? ' - On sale: ₹${p.discountedPrice}' : ''})',
        )
        .join(', ');

    return '''
You are BuyM8, a helpful shopping assistant for our e-commerce store.

Store Information:
- We sell products across multiple categories
- Available categories: ${categoryNames.isNotEmpty ? categoryNames : 'Electronics, Fashion, Home & Kitchen, Books, Sports'}
- Sample products: ${sampleProducts.isNotEmpty ? sampleProducts : 'Various products available'}
- We offer discounts for registered users through discount groups
- Payment methods: Credit/Debit cards, UPI, Net banking, Cash on delivery
- Order statuses: Pending, Paid, Processing, Shipped, Delivered, Cancelled

Your Role:
1. Help users find products they're looking for
2. Provide product recommendations based on their needs
3. Answer questions about pricing, availability, and features
4. Explain our discount system and how users can save money
5. Help with order tracking and status
6. Assist with general shopping queries
7. Be friendly, concise, and helpful

Important Guidelines:
- Keep responses short and conversational (2-4 sentences typically)
- If users ask about specific products not in your context, be honest that you need to search
- Encourage users to browse categories or use search for specific items
- When discussing prices, mention if discounts are available for registered users
- For order-related queries, direct users to their order history page
- If questions are completely unrelated to shopping, politely redirect to shopping topics

Remember: Be natural and helpful, not robotic. Think of yourself as a friendly store assistant.
''';
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> clearChat() async {
    try {
      await DatabaseHelper.instance.clearAllData();
      messages.clear();
      AppSnackbars.success('Success', 'Chat cleared successfully');
    } catch (e) {
      AppSnackbars.error('Error', 'Failed to clear chat');
    }
  }
}
