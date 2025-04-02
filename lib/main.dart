import 'package:chaty/models/message.dart';
import 'package:chaty/services/notification_services.dart';
import 'package:chaty/ui/chat_list_screen.dart';
import 'package:chaty/ui/chat_screen.dart';
import 'package:chaty/utils/extensions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chaty Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(), // Initial screen
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _user1Controller = TextEditingController();
  final TextEditingController _user2Controller = TextEditingController();

  final textEditingController = TextEditingController();

  final ValueNotifier<DateTime> _lastSeen = ValueNotifier(DateTime.now());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chaty Example")),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: _user1Controller,
              decoration: const InputDecoration(
                hintText: "Enter your name",
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _user2Controller,
              decoration: const InputDecoration(
                hintText: "Enter another user's name",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to ChatScreen with sample data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      getLastSeen: (lastSeen) {
                        _lastSeen.value = lastSeen.log('Last seen');
                      },
                      intialChatLimit: 15,
                      senderId: _user1Controller.text,
                      receiverId: _user2Controller.text,
                      messageBubbleBuilder: (
                          {required isMe, required message}) {
                        return _MessageBubble(isMe: isMe, message: message);
                      },
                      sendMessageBuilder: (context,
                          {required sendMediaMessage, required sendMessage}) {
                        return Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: () async {},
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: "Type a message",
                                ),
                                controller: textEditingController,
                                onSubmitted: (value) {
                                  sendMessage(value);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                sendMessage(textEditingController.text);
                              },
                              onLongPress: () async {
                                for (int i = 0; i < 100; i++) {
                                  Future.delayed(
                                    const Duration(seconds: 1),
                                    () {
                                      sendMessage("Message $i");
                                    },
                                  );
                                }
                              },
                              child: const Icon(Icons.send),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
              child: const Text("Start Chat"),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatListScreen(
                                currentUserId: _user1Controller.text,
                                chatTileBuilder: ({required chatSummary}) {
                                  return ListTile(
                                    leading: chatSummary.unreadCount > 0
                                        ? CircleAvatar(
                                            backgroundColor: Colors.red,
                                            radius: 6,
                                          )
                                        : SizedBox(), // ✅ Show dot if unreadCount > 0,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatScreen(
                                            intialChatLimit: 15,
                                            senderId: _user1Controller.text,
                                            receiverId: chatSummary.otherUserId,
                                            messageBubbleBuilder: (
                                                {required isMe,
                                                required message}) {
                                              return _MessageBubble(
                                                  isMe: isMe, message: message);
                                            },
                                            sendMessageBuilder: (context,
                                                {required sendMediaMessage,
                                                required sendMessage}) {
                                              return Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.camera_alt),
                                                    onPressed: () async {},
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: TextField(
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText:
                                                            "Type a message",
                                                      ),
                                                      controller:
                                                          textEditingController,
                                                      onSubmitted: (value) {
                                                        sendMessage(value);
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  GestureDetector(
                                                    onLongPress: () async {
                                                      for (int i = 0;
                                                          i < 100;
                                                          i++) {
                                                        Future.delayed(
                                                          const Duration(
                                                              seconds: 1),
                                                          () {
                                                            sendMessage(
                                                                "Message $i");
                                                          },
                                                        );
                                                      }
                                                    },
                                                    child: IconButton(
                                                      icon: const Icon(
                                                          Icons.send),
                                                      onPressed: () {
                                                        sendMessage(
                                                            textEditingController
                                                                .text);
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    title: Text(chatSummary.otherUserId),
                                    subtitle: Text(chatSummary.lastMessage),
                                    trailing: Text(
                                      chatSummary.lastMessageTime
                                          .toLocal()
                                          .timeAgo(),
                                    ),
                                  );
                                },
                              )));
                },
                child: Text('list of messages')),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.isMe,
    required this.message,
  });
  final bool isMe;
  final Message message;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.mediaUrl != null)
              Image.network(
                message.mediaUrl!,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            if (message.text.isNotEmpty)
              Text(
                message.text,
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 5),
            Text(
              message.timestamp.toLocal().timeAgo(),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
