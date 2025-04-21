import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;
import '../models/message.dart';
import '../widgets/chat_message.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isComposing = false;

  // Enhanced color scheme
  final Color _primaryColor = const Color(0xff4caf50);
  final Color _accentColor = const Color(0xff81c784);
  final Color _lightGreen = const Color(0xffc8e6c9);
  final Color _darkGreen = const Color(0xff2e7d32);

  // Animation controller
  late AnimationController _typingController;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _messages.add(
      Message(
        "👋 Hello! I'm your nutrition assistant. Here are some things you can ask me:\n\n"
        "• \"I need 100g of protein, suggest food options\"\n"
        "• \"I am calcium deficient, what should I eat?\"\n"
        "• \"Food sources high in vitamin C\"\n"
        "• \"I need 2000 calories, what's a sample meal plan?\"",
        false,
        isMarkdown: true,
      ),
    );
  }

  @override
  void dispose() {
    _typingController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _handleSubmitted(String text) async {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });

    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(text, true));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        throw Exception('API key not found. Please check your .env file.');
      }

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {
              'role': 'system',
              'content': '''
              You are a helpful nutrition assistant. When users ask about nutritional needs:
              
              1. If they mention a specific nutrient amount (like "100g protein"), suggest 5 food options with approximate serving sizes to reach that amount.
              
              2. If they mention a deficiency (like "calcium deficient"), suggest the top 5 foods rich in that nutrient, daily requirements, and serving suggestions.
              
              3. Include brief nutritional information for each food suggestion.
              
              Format your response with markdown (using ** for bold, - for bullet points, etc.).
              '''
            },
            {
              'role': 'user',
              'content': text,
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final advice = data['choices'][0]['message']['content'];

        setState(() {
          _messages.add(Message(advice, false, isMarkdown: true));
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error: $e');
      setState(() {
        _messages.add(
            Message('Sorry, something went wrong. Please try again.', false));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NutriSearch Assistant',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back, // Back icon
            color: Colors.white, // Make the back icon white
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              _showInfoDialog();
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primaryColor, _darkGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          image: DecorationImage(
            image: const AssetImage('assets/images/nutrition_bg.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.1),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (_, int index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessageItem(_messages[index], index);
                },
              ),
            ),
            const Divider(height: 1.0, color: Colors.transparent),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black12,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: _buildTextComposer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16, left: 8, right: 80),
      decoration: BoxDecoration(
        color: _lightGreen,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _typingController,
            builder: (context, child) {
              return Row(
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(
                        0.5 +
                            (_typingController.value - index * 0.3)
                                .clamp(0.0, 0.5),
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            'Typing...',
            style: TextStyle(
              color: _darkGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Message message, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      margin: EdgeInsets.only(
        bottom: 16.0,
        left: message.isUser ? 80.0 : 8.0,
        right: message.isUser ? 8.0 : 80.0,
      ),
      child: Material(
        elevation: 2.0,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: message.isUser ? const Radius.circular(20) : Radius.zero,
          bottomRight: message.isUser ? Radius.zero : const Radius.circular(20),
        ),
        color: message.isUser ? _accentColor : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isUser && index == 0) ...[
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: _lightGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.food_bank, color: _darkGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Nutrition Assistant',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _darkGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (message.isMarkdown)
                MarkdownBody(
                  data: message.text,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                    strong: TextStyle(
                      color: message.isUser ? Colors.white : _darkGreen,
                      fontWeight: FontWeight.bold,
                    ),
                    listBullet: TextStyle(
                      color: message.isUser ? Colors.white : _primaryColor,
                    ),
                  ),
                )
              else
                Text(
                  message.text,
                  style: TextStyle(
                    color: message.isUser ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!message.isUser) ...[
                    GestureDetector(
                      onTap: () {
                        _copyToClipboard(message.text);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.copy,
                          size: 16,
                          color: _primaryColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    // Copy to clipboard functionality would be implemented here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        backgroundColor: _darkGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(8),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.emoji_emotions_outlined,
              color: _primaryColor,
            ),
            onPressed: () {
              // Emoji picker would be implemented here
            },
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onChanged: (text) {
                        setState(() {
                          _isComposing = text.trim().isNotEmpty;
                        });
                      },
                      onSubmitted: _isLoading ? null : _handleSubmitted,
                      decoration: InputDecoration(
                        hintText: "Ask about nutrition...",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        border: InputBorder.none,
                      ),
                      cursorColor: _primaryColor,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      maxLines: null,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.mic,
                      color: _isComposing ? Colors.grey : _primaryColor,
                    ),
                    onPressed: _isComposing
                        ? null
                        : () {
                            // Voice input would be implemented here
                          },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            decoration: BoxDecoration(
              color: _isComposing ? _primaryColor : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                icon: const Icon(Icons.send),
                color: _isComposing ? Colors.white : Colors.grey[500],
                onPressed: _isLoading || !_isComposing
                    ? null
                    : () => _handleSubmitted(_textController.text),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'About NutriSearch',
          style: TextStyle(
            color: _darkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NutriSearch is your personal nutrition assistant that provides information about foods, nutrients, and dietary recommendations.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Features:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Get food suggestions for specific nutrient targets'),
              Text('• Learn about rich food sources for vitamins and minerals'),
              Text('• Receive dietary advice for nutritional deficiencies'),
              Text('• Get sample meal plans based on caloric needs'),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: _primaryColor,
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
