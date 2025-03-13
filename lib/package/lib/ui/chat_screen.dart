import 'dart:async';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import 'message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String senderId;
  final String receiverId;

  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _isLoadingMore = false;
  Message? _lastMessage;
  bool _hasMoreMessages = true;
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _fetchInitialMessages();
    _markMessagesAsRead();
  }

  /// Fetch the first batch of messages with real-time updates
  Future<void> _fetchInitialMessages() async {
    _chatService.streamLatestMessages(widget.chatId).listen((newMessages) {
      setState(() {
        if (_messages.isEmpty) {
          _messages = newMessages;
        } else {
          for (var msg in newMessages) {
            if (!_messages.any((m) => m.messageId == msg.messageId)) {
              _messages.insert(0, msg);
            }
          }
        }
        if (_messages.isNotEmpty) {
          _lastMessage = _messages.last; // Save last message for pagination
        }
      });
      _markMessagesAsRead();
    });
  }

  /// Mark all messages as read
  void _markMessagesAsRead() {
    _chatService.markMessagesAsRead(widget.chatId, widget.senderId);
  }

  /// Load older messages when pulling down
  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore || !_hasMoreMessages || _lastMessage == null) return;
    setState(() => _isLoadingMore = true);

    List<Message> olderMessages = await _chatService.fetchMessages(
        _chatService.getChatId(widget.senderId, widget.receiverId),
        lastMessage: _lastMessage);
    if (olderMessages.isNotEmpty) {
      setState(() {
        _messages.addAll(olderMessages);
        _lastMessage = olderMessages.last; // Update last message for pagination
      });
    } else {
      setState(() => _hasMoreMessages = false); // No more messages to load
    }

    setState(() => _isLoadingMore = false);
  }

  /// Send a message
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    Message message = Message(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: widget.senderId,
      receiverId: widget.receiverId,
      text: _messageController.text.trim(),
      mediaUrl: null,
      timestamp: DateTime.now(),
      status: MessageStatus.unread,
    );

    _chatService.sendMessage(message);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      floatingActionButton: FloatingActionButton(onPressed: _loadMoreMessages),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(
                  message: _messages[index],
                  isMe: _messages[index].senderId == widget.senderId,
                );
              },
            ),
          ),

          if (_isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),

          // Message Input Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
