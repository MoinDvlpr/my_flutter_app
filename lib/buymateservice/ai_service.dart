import 'dart:convert';
import 'package:dio/dio.dart';

class GroqAIService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  final String apiKey;
  late final Dio _dio;

  GroqAIService({required this.apiKey}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      ),
    );

    // Add interceptors for logging (optional - disable in production)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: false, // Set to false to reduce logs
        error: true,
        logPrint: (log) => print('[AI Service] $log'),
      ),
    );
  }

  Future<String> sendMessage({
    required String userMessage,
    required List<Map<String, dynamic>> conversationHistory,
    String? storeContext,
  }) async {
    try {
      // Build messages array with system prompt
      List<Map<String, dynamic>> messages = [
        {
          'role': 'system',
          'content': storeContext ?? _getDefaultSystemPrompt(),
        },
        ...conversationHistory,
        {'role': 'user', 'content': userMessage},
      ];

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'llama-3.1-70b-versatile',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1024,
          'top_p': 1,
          'stream': false,
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        return content ?? 'I apologize, but I couldn\'t generate a response.';
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to get AI response: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('[AI Service Error] ${e.message}');
      if (e.response != null) {
        print('[AI Service Error Details] ${e.response?.data}');
        throw Exception(
          'AI Service Error: ${e.response?.statusCode} - ${e.response?.data}',
        );
      } else {
        throw Exception('AI Service Error: ${e.message}');
      }
    } catch (e) {
      print('[AI Service Unexpected Error] $e');
      throw Exception('Unexpected Error: $e');
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
          'role': 'system',
          'content': storeContext ?? _getDefaultSystemPrompt(),
        },
        ...conversationHistory,
        {'role': 'user', 'content': userMessage},
      ];

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'llama-3.1-70b-versatile',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1024,
          'stream': true,
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
        ),
      );

      // Process the stream
      await for (var chunk in (response.data.stream as Stream).transform(
        utf8.decoder,
      )) {
        final lines = chunk.split('\n');
        for (var line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data.trim() == '[DONE]') continue;

            try {
              final json = jsonDecode(data);
              final content = json['choices']?[0]?['delta']?['content'];
              if (content != null && content.isNotEmpty) {
                yield content;
              }
            } catch (e) {
              // Skip malformed JSON chunks
              print('[AI Stream Parse Error] $e');
            }
          }
        }
      }
    } on DioException catch (e) {
      print('[AI Stream Error] ${e.message}');
      yield 'Sorry, I encountered an error. Please try again.';
    } catch (e) {
      print('[AI Stream Unexpected Error] $e');
      yield 'Sorry, something went wrong. Please try again.';
    }
  }

  String _getDefaultSystemPrompt() {
    return '''You are a helpful shopping assistant for an e-commerce store app. 
Your role is to:
- Help users find products
- Provide product recommendations
- Answer questions about orders, products, and store policies
- Assist with product comparisons
- Give shopping advice

Keep responses concise, friendly, and shopping-focused. If a question is not related to shopping, politely redirect the user.''';
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

    throw Exception('Failed after $maxRetries attempts');
  }
}
