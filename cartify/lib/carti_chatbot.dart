import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'colors.dart';
import 'database_functions.dart';

// Carti AI Chatbot Page with Groq Integration
class CartiChatbotPage extends StatefulWidget {
  const CartiChatbotPage({super.key});

  @override
  State<CartiChatbotPage> createState() => _CartiChatbotPageState();
}

class _CartiChatbotPageState extends State<CartiChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  String userName = "Guest";
  bool _isTyping = false;

  // UPDATED: Your Groq API key
  final String apiKey = String.fromEnvironment('GROQ_API_KEY');

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _sendWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Load user name from Firebase
  Future<void> _loadUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final userData = await DatabaseService.instance.getUser(userId);
      if (userData != null && mounted) {
        setState(() {
          userName = userData['name'] ?? 'Guest';
        });
      }
    }
  }

  // Send welcome message
  Future<void> _sendWelcomeMessage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Hi $userName! 👋 I'm Carti, your shopping assistant. How can I help you today?",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  // Get current app context for AI
  Future<String> _getAppContext() async {
    try {
      final categories = await DatabaseService.instance.getCategories();
      final products = await DatabaseService.instance.getAllProducts();

      // Build detailed context
      String context = "You are Carti, a friendly shopping assistant for Cartify app.\n\n";
      context += "AVAILABLE CATEGORIES (${categories.length} total):\n";

      for (var category in categories) {
        context += "- ${category['title']} (Parent: ${category['parentCategory'] ?? 'None'})\n";
      }

      context += "\nAVAILABLE PRODUCTS (${products.length} total):\n";

      for (var product in products.take(20)) { // Limit to first 20 to avoid token limits
        context += "- ${product['name']} - Rs.${product['price']} ";
        context += "(Category: ${product['categoryId']}, Gender: ${product['gender'] ?? 'N/A'})\n";
      }

      if (products.length > 20) {
        context += "... and ${products.length - 20} more products\n";
      }

      context += "\nYou can help users:\n";
      context += "- Find products by name, price, category, or gender\n";
      context += "- Provide shopping tips and recommendations\n";
      context += "- Answer questions about categories and available items\n";
      context += "- Give advice on fashion and style\n";

      return context;
    } catch (e) {
      return "You are Carti, a friendly shopping assistant for Cartify, a general shopping app.";
    }
  }

  // Logic using Groq API
  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final appContext = await _getAppContext();

      // Using Groq API endpoint
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile', // Active Groq model (recommended)
          'messages': [
            {
              'role': 'system',
              'content': appContext,
            },
            {
              'role': 'user',
              'content': message,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];

        if (mounted) {
          setState(() {
            _messages.add(ChatMessage(
              text: aiResponse,
              isUser: false,
              timestamp: DateTime.now(),
            ));
            _isTyping = false;
          });
          _scrollToBottom();
        }
      } else {
        // Parse error details
        String errorMsg = "API Error ${response.statusCode}\n\n";
        try {
          final errorData = jsonDecode(response.body);
          errorMsg += "Error Type: ${errorData['error']?['type'] ?? 'Unknown'}\n";
          errorMsg += "Message: ${errorData['error']?['message'] ?? response.body}\n";
          errorMsg += "Code: ${errorData['error']?['code'] ?? 'N/A'}";
        } catch (e) {
          errorMsg += "Raw Response: ${response.body}";
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Chatbot Error: $e');
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: "❌ ERROR DETAILS:\n\n$e\n\n💡 Possible fixes:\n• Check your Groq API key\n• Verify internet connection\n• Try again in a moment",
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isTyping = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildQuickAction(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton.icon(
        onPressed: () => _sendMessage(text),
        icon: Icon(icon, size: 16, color: AppColors.accent),
        label: Text(text, style: TextStyle(color: AppColors.accent, fontSize: 12, fontFamily: 'ADLaMDisplay')),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          side: BorderSide(color: AppColors.accent),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.accent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.smart_toy, color: AppColors.accent, size: 24),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Carti AI', style: TextStyle(color: Colors.white, fontFamily: 'IrishGrover', fontSize: 20)),
                Text('Your Shopping Assistant', style: TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'ADLaMDisplay')),
              ],
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          if (_messages.length <= 1)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.card, border: Border(bottom: BorderSide(color: AppColors.border))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quick questions:', style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'ADLaMDisplay')),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickAction("What products?", Icons.inventory_2),
                        _buildQuickAction("Show me categories", Icons.category),
                        _buildQuickAction("Shopping tips", Icons.lightbulb),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
            ),
          ),
          if (_isTyping) _buildTypingIndicator(),
          _buildMessageInputArea(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _buildTypingDot(i)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Container(
          width: 8, height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.3 + (0.7 * ((value + index * 0.3) % 1.0))), shape: BoxShape.circle),
        );
      },
      onEnd: () { if (mounted) setState(() {}); },
    );
  }

  Widget _buildMessageInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, border: Border(top: BorderSide(color: AppColors.border))),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black, // Changed to black
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(color: Colors.white, fontFamily: 'ADLaMDisplay'), // White text for visibility
                  decoration: InputDecoration(
                    hintText: 'Ask Carti anything...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), // Semi-transparent white hint
                    border: InputBorder.none,
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () => _sendMessage(_messageController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.accent : AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: message.isUser ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : AppColors.textPrimary,
            fontFamily: 'ADLaMDisplay',
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}