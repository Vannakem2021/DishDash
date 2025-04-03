import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';
import '../utils/app_theme.dart';
import '../utils/session_manager.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatRepository _chatRepository = ChatRepository();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  int? _userId;
  String? _userEmail;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Get current user ID and email
    final userId = await SessionManager.getUserId();
    final userEmail = await SessionManager.getUserEmail();

    if (userId == null) {
      // Guest user or error
      print('Error: No user ID found for chat');
      return;
    }

    setState(() {
      _userId = userId;
      _userEmail = userEmail;
    });

    // Load user's chat messages
    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_userId == null) {
        throw Exception('Cannot load messages: No user ID');
      }

      // Get messages from the database
      final messages = await _chatRepository.getMessagesForUser(_userId!);

      // If no messages exist, add initial welcome message
      if (messages.isEmpty) {
        final initialMessages = _chatRepository.getInitialMessages(_userId!);

        // Save initial messages to database
        for (var message in initialMessages) {
          await _chatRepository.saveMessage(message);
        }

        setState(() {
          _messages = initialMessages;
          _isLoading = false;
        });
      } else {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
      }

      // Scroll to bottom when screen loads
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      print('Error loading chat messages: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _userId == null) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    // Create and save user message
    final userMessage = ChatMessage(
      userId: _userId!,
      message: messageText,
      isFromUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    // Save to database
    await _chatRepository.saveMessage(userMessage);

    // Scroll to show new message
    _scrollToBottom();

    // Simulate bot typing (1-2 seconds based on message length)
    final typingDuration = Duration(
      milliseconds: 1000 + (messageText.length * 20).clamp(0, 2000),
    );

    await Future.delayed(typingDuration);

    // Generate and save bot response
    final botResponse = await _chatRepository.generateResponse(
      _userId!,
      messageText,
    );
    await _chatRepository.saveMessage(botResponse);

    setState(() {
      _isTyping = false;
      _messages.add(botResponse);
    });

    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Support'),
        elevation: 1,
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildChatHeader(),
                  Expanded(
                    child:
                        _messages.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
                              ),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final message = _messages[index];
                                final isLastMessageFromSameSender =
                                    index > 0 &&
                                    _messages[index - 1].isFromUser ==
                                        message.isFromUser;

                                // Only show timestamp for the last message in a series
                                final shouldShowTimestamp =
                                    index == _messages.length - 1 ||
                                    _messages[index + 1].isFromUser !=
                                        message.isFromUser;

                                return _buildMessageBubble(
                                  message,
                                  isLastMessageFromSameSender,
                                  shouldShowTimestamp,
                                );
                              },
                            ),
                  ),
                  if (_isTyping) _buildTypingIndicator(),
                  _buildMessageInput(),
                ],
              ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildRobotAvatar(32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'DishDash Support Bot',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ask me anything about your orders or our service',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildRobotAvatar(80),
          const SizedBox(height: 24),
          const Text(
            'Start a conversation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Ask anything about your orders, menu items, or get help with your account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              _messageController.text = "Hi, I need help with my order";
              _sendMessage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Start a Conversation'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    ChatMessage message,
    bool isLastMessageFromSameSender,
    bool shouldShowTimestamp,
  ) {
    final isFromUser = message.isFromUser;

    return Padding(
      padding: EdgeInsets.only(
        top: isLastMessageFromSameSender ? 4 : 16,
        bottom: shouldShowTimestamp ? 4 : 0,
      ),
      child: Row(
        mainAxisAlignment:
            isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFromUser) _buildBotAvatar(isLastMessageFromSameSender),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isFromUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isFromUser ? AppTheme.primaryColor : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      color: isFromUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (shouldShowTimestamp)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                    child: Text(
                      _formatTimestamp(message.timestamp),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isFromUser) _buildUserAvatar(isLastMessageFromSameSender),
        ],
      ),
    );
  }

  Widget _buildBotAvatar(bool isLastMessageFromSameSender) {
    if (isLastMessageFromSameSender) {
      return const SizedBox(width: 32);
    }

    return _buildRobotAvatar(32);
  }

  Widget _buildRobotAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.primaryColor, width: 2),
      ),
      child: Center(
        child: Icon(
          Icons.smart_toy_rounded,
          color: AppTheme.primaryColor,
          size: size * 0.6,
        ),
      ),
    );
  }

  Widget _buildUserAvatar(bool isLastMessageFromSameSender) {
    if (isLastMessageFromSameSender) {
      return const SizedBox(width: 32);
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Icon(Icons.person, color: Colors.grey[700], size: 18),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          _buildRobotAvatar(24),
          const SizedBox(width: 8),
          const Text(
            'Bot is typing',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 8),
          _buildDot(1),
          _buildDot(2),
          _buildDot(3),
        ],
      ),
    );
  }

  Widget _buildDot(int position) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 * position),
      builder: (context, double value, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: value > 0.5 ? AppTheme.primaryColor : Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    String minutes = timestamp.minute.toString().padLeft(2, '0');
    String hours = timestamp.hour.toString();

    if (messageDate == today) {
      return '$hours:$minutes';
    } else {
      return '${timestamp.day}/${timestamp.month}, $hours:$minutes';
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
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
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type here...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
                maxLines: null,
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                _buildRobotAvatar(24),
                const SizedBox(width: 8),
                const Text('DishDash Support Bot'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This is an automated support chat powered by AI. '
                  'The bot can help you with:',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text('• Order tracking and status updates'),
                Text('• Menu information and special offers'),
                Text('• Account and payment options'),
                Text('• Delivery questions'),
                SizedBox(height: 16),
                Text(
                  'For complex issues, please contact our human support team at support@dishdash.com',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK, GOT IT'),
              ),
            ],
          ),
    );
  }
}
