import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/common/bottom_nav.dart';

class AIMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestedActions;

  const AIMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.suggestedActions,
  });
}

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AIMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = AIMessage(
      id: 'welcome',
      content: 'Hello! I\'m your AVC AI Assistant. I can help you with:\n\n'
          '• Device troubleshooting\n'
          '• Performance optimization\n'
          '• Configuration recommendations\n'
          '• Health monitoring insights\n\n'
          'How can I assist you today?',
      isUser: false,
      timestamp: DateTime.now(),
      suggestedActions: [
        'Check device health',
        'Optimize settings',
        'Troubleshoot connection',
        'View recommendations',
      ],
    );
    
    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  void _sendMessage(String content) {
    if (content.trim().isEmpty) return;

    final userMessage = AIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      final aiResponse = _generateAIResponse(content);
      setState(() {
        _messages.add(aiResponse);
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  AIMessage _generateAIResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    String response;
    List<String>? actions;

    if (lowerMessage.contains('health') || lowerMessage.contains('status')) {
      response = 'Based on your device metrics, everything looks good! Your AVC Mask Pro has:\n\n'
          '• Signal strength: 85% (Excellent)\n'
          '• Battery level: 92% (Great)\n'
          '• Latency: 45ms (Good)\n'
          '• Sensor accuracy: 94% (Excellent)\n\n'
          'I recommend checking the battery level regularly and ensuring good WiFi signal for optimal performance.';
      actions = ['View detailed metrics', 'Set up alerts', 'Schedule health check'];
    } else if (lowerMessage.contains('optimize') || lowerMessage.contains('settings')) {
      response = 'I can help optimize your device settings! Based on your usage patterns, I recommend:\n\n'
          '• Increase sensitivity to 65% for better voice detection\n'
          '• Enable adaptive mode for automatic adjustments\n'
          '• Set response time to 20ms for faster reactions\n\n'
          'Would you like me to apply these optimizations?';
      actions = ['Apply optimizations', 'View current settings', 'Custom configuration'];
    } else if (lowerMessage.contains('troubleshoot') || lowerMessage.contains('problem') || lowerMessage.contains('issue')) {
      response = 'I\'m here to help troubleshoot! Common solutions include:\n\n'
          '• Check WiFi connection strength\n'
          '• Restart the device if unresponsive\n'
          '• Verify battery level is above 20%\n'
          '• Ensure device is within 10 meters of router\n\n'
          'What specific issue are you experiencing?';
      actions = ['Run diagnostics', 'Check connections', 'Contact support'];
    } else if (lowerMessage.contains('battery')) {
      response = 'Your device battery is currently at 92% - excellent level! Here are some battery tips:\n\n'
          '• Battery typically lasts 8-12 hours with normal use\n'
          '• Charge when below 20% for optimal battery health\n'
          '• Reduce volume and sensitivity to extend battery life\n'
          '• Enable power saving mode when needed\n\n'
          'I can set up low battery alerts if you\'d like.';
      actions = ['Set battery alerts', 'Enable power saving', 'View battery history'];
    } else {
      response = 'I understand you\'re asking about "${userMessage}". While I\'m still learning, I can help with:\n\n'
          '• Device health monitoring\n'
          '• Performance optimization\n'
          '• Troubleshooting common issues\n'
          '• Configuration recommendations\n\n'
          'Could you please be more specific about what you need help with?';
      actions = ['Ask about health', 'Get optimization tips', 'Troubleshoot issues'];
    }

    return AIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: response,
      isUser: false,
      timestamp: DateTime.now(),
      suggestedActions: actions,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              setState(() {
                _messages.clear();
              });
              _addWelcomeMessage();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask me anything about your AVC device...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _sendMessage(_messageController.text),
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  Widget _buildMessageBubble(AIMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.smart_toy, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: message.isUser
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (message.suggestedActions != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: message.suggestedActions!.map((action) {
                      return ActionChip(
                        label: Text(action),
                        onPressed: () => _sendMessage(action),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.smart_toy, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('AI is typing...'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}