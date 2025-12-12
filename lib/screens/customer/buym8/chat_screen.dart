import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_flutter_app/widgets/appbar_with_cart.dart';
import '../../../controllers/ai_controller.dart';
import '../../../model/chat_model.dart';
import '../../../utils/app_colors.dart';

class AIChatScreen extends StatelessWidget {
  AIChatScreen({super.key});

  // Find controller here to use
  final aiCtr = Get.find<AIController>();

  // ---------- UI BUBBLE DESIGN ----------
  Widget _messageBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isUser ? 80 : 16,
          right: isUser ? 16 : 80,
          bottom: 16,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFFE3C72) : const Color(0xFFECECEC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          msg.message,
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  // ---------- TYPING INDICATOR ----------
  Widget _typingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFFE3C72),
            child: Icon(Icons.smart_toy, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Typing"),
                const SizedBox(width: 8),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey[600]!,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- EMPTY STATE ----------
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "Hello! I'm BuyM8 👋",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your shopping assistant",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Ask me about products, recommendations, orders, or anything related to shopping!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: appBarWithCart(
        title: "BuyM8 - AI Assistant",
        // actions: [
          // Optional: Add clear chat button
          // IconButton(
          //   icon: const Icon(Icons.delete_outline),
          //   onPressed: () {
          //     Get.defaultDialog(
          //       title: "Clear Chat",
          //       middleText: "Are you sure you want to clear all messages?",
          //       textConfirm: "Clear",
          //       textCancel: "Cancel",
          //       confirmTextColor: Colors.white,
          //       onConfirm: () {
          //         aiCtr.clearChat();
          //         Get.back();
          //       },
          //     );
          //   },
          // ),
        // ],
      ),
      body: Obx(
            () => Column(
          children: [
            // Messages Area
            Expanded(
              child: aiCtr.messages.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                controller: aiCtr.scrollController,
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                itemCount: aiCtr.messages.length,
                itemBuilder: (_, i) => _messageBubble(aiCtr.messages[i]),
              ),
            ),

            // Typing Indicator
            if (aiCtr.isTyping.value) _typingIndicator(),

            // Input Bar
            Container(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 30,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: aiCtr.messageController,
                        decoration: const InputDecoration(
                          hintText: 'Ask me anything...',
                          fillColor: Color(0xFFF5F5F5),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.black45),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => aiCtr.sendMessage(),
                        enabled: !aiCtr.isLoading.value && !aiCtr.isTyping.value,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: aiCtr.isLoading.value || aiCtr.isTyping.value
                        ? null
                        : aiCtr.sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: aiCtr.isLoading.value || aiCtr.isTyping.value
                            ? Colors.grey[400]
                            : const Color(0xFFFE3C72),
                        shape: BoxShape.circle,
                      ),
                      child: aiCtr.isLoading.value
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}