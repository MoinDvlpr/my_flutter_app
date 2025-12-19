import "dart:convert";
import "dart:typed_data";
import "package:dio/dio.dart";

class GroqAIService {
  static const String _baseUrl = "https://api.groq.com/openai/v1";
  final String apiKey;
  late final Dio _dio;

  GroqAIService({required this.apiKey}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
      ),
    );

    // Add interceptors for logging (optional - disable in production)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: false,
        error: true,
        logPrint: (log) => print("[AI Service] $log"),
      ),
    );
  }

  // Non-streaming response
  Future<String> sendMessage({
    required String userMessage,
    required List<Map<String, dynamic>> conversationHistory,
    String? storeContext,
  }) async {
    try {
      List<Map<String, dynamic>> messages = [
        {
          "role": "system",
          "content": storeContext ?? _getDefaultSystemPrompt(),
        },
        ...conversationHistory,
        {"role": "user", "content": userMessage},
      ];

      final response = await _dio.post(
        "/chat/completions",
        data: {
          "model": "openai/gpt-oss-120b",
          "messages": messages,
          "temperature": 0.7,
          "max_tokens": 1024,
          "top_p": 1,
          "stream": false, // Changed to false for non-streaming
        },
      );

      if (response.statusCode == 200) {
        final content = response.data["choices"][0]["message"]["content"];
        return content ?? "I apologize, but I couldn't generate a response.";
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: "Failed to get AI response: ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      print("[AI Service Error] ${e.message}");
      if (e.response != null) {
        print("[AI Service Error Details] ${e.response?.data}");
        throw Exception(
          "AI Service Error: ${e.response?.statusCode} - ${e.response?.data}",
        );
      } else {
        throw Exception("AI Service Error: ${e.message}");
      }
    } catch (e) {
      print("[AI Service Unexpected Error] $e");
      throw Exception("Unexpected Error: $e");
    }
  }

  // Stream response for real-time typing effect
  Stream<String> sendMessageStream({
    required String userMessage,
    required List<Map<String, dynamic>> conversationHistory,
    String? storeContext,
  }) async* {
    try {
      List<Map<String, dynamic>> messages = [
        {
          "role": "system",
          "content": storeContext ?? _getDefaultSystemPrompt(),
        },
        ...conversationHistory,
        {"role": "user", "content": userMessage},
      ];

      final response = await _dio.post(
        "/chat/completions",
        data: {
          "model": "openai/gpt-oss-120b",
          "messages": messages,
          "temperature": 0.7,
          "max_tokens": 1024,
          "stream": true,
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {"Accept": "text/event-stream"},
        ),
      );

      if (response.statusCode != 200) {
        yield "Error: Failed to connect to AI service";
        return;
      }

      String buffer = '';

      final stream = response.data!.stream as Stream<Uint8List>;

      await for (final chunk in stream) {
        // Decode bytes to string
        final decoded = utf8.decode(chunk, allowMalformed: true);
        buffer += decoded;

        // Process complete lines
        while (buffer.contains('\n')) {
          final newlineIndex = buffer.indexOf('\n');
          final line = buffer.substring(0, newlineIndex).trim();
          buffer = buffer.substring(newlineIndex + 1);

          // Skip empty lines or comments
          if (line.isEmpty || !line.startsWith('data: ')) {
            continue;
          }

          // Extract data after "data: " prefix
          final data = line.substring(6).trim();

          // Check for end of stream
          if (data == '[DONE]') {
            return;
          }

          // Parse JSON and extract content
          try {
            final json = jsonDecode(data);
            final delta = json['choices']?[0]?['delta'];
            final content = delta?['content'];

            if (content != null && content is String && content.isNotEmpty) {
              yield content;
            }
          } catch (e) {
            // Skip malformed JSON chunks
            print("[Stream Parse Warning] Failed to parse: $data");
            continue;
          }
        }
      }

      // Process any remaining buffer content
      if (buffer.isNotEmpty && buffer.startsWith('data: ')) {
        final data = buffer.substring(6).trim();
        if (data != '[DONE]') {
          try {
            final json = jsonDecode(data);
            final delta = json['choices']?[0]?['delta'];
            final content = delta?['content'];
            if (content != null && content is String && content.isNotEmpty) {
              yield content;
            }
          } catch (e) {
            print("[Stream Parse Warning] Failed to parse remaining buffer");
          }
        }
      }
    } on DioException catch (e) {
      print("[AI Stream Error] ${e.message}");
      if (e.response != null) {
        print("[AI Stream Error Details] ${e.response?.data}");
      }
      yield "Sorry, I encountered an error. Please try again.";
    } catch (e) {
      print("[AI Stream Unexpected Error] $e");
      yield "Sorry, something went wrong. Please try again.";
    }
  }

  String _getDefaultSystemPrompt() {
    return """You are a helpful shopping assistant for an e-commerce store app. 
Your role is to:
- Help users find products
- Provide product recommendations
- Answer questions about orders, products, and store policies
- Assist with product comparisons
- Give shopping advice

Keep responses concise, friendly, and shopping-focused. If a question is not related to shopping, politely redirect the user.""";
  }

  // Cancel any ongoing requests
  void cancelRequests() {
    _dio.close(force: true);
  }

  // Retry logic for failed requests
  Future<String> sendMessageWithRetry({
    required String userMessage,
    required List<Map<String, dynamic>> conversationHistory,
    String? storeContext,
    int maxRetries = 3,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await sendMessage(
          userMessage: userMessage,
          conversationHistory: conversationHistory,
          storeContext: storeContext,
        );
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          rethrow;
        }
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }

    throw Exception("Failed after $maxRetries attempts");
  }
}
