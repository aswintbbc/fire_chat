import 'package:chaty/models/message.dart';
import 'package:chaty/models/user_info.dart';
import 'package:chaty/services/chat_service.dart';
import 'package:chaty/ui/chat_screen.dart';
import 'package:chaty/utils/extensions.dart';
import 'package:fire_chat/widgets/audio_recorder_widget.dart';
import 'package:fire_chat/helper/file_picker.dart';
import 'package:fire_chat/widgets/message_bubble.dart';
import 'package:fire_chat/widgets/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatViewScreen extends StatefulWidget {
  const ChatViewScreen({super.key, required this.user1, required this.user2});
  final String user1, user2;
  @override
  State<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends State<ChatViewScreen> {
  final textEditingController = TextEditingController();
  ValueNotifier<List<Message>> selectedController =
      ValueNotifier<List<Message>>([]); // Initialize the selected controller
  late void Function() deselectAll;
  late void Function() deleteAll;
  final ValueNotifier<DateTime> _lastSeen = ValueNotifier(DateTime.now());

  Timer? timer;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: StreamBuilder<SenderInfo>(
          stream: ChatService.instance.getSenderInfo(widget.user2),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Icon(Icons.error);
            } else {
              return CircleAvatar(
                backgroundImage: snapshot.data!.imageUrl != null
                    ? NetworkImage(snapshot.data!.imageUrl!)
                    : null,
              );
            }
          },
        ),
        title: Text(
          '${widget.user1} - ${widget.user2}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: selectedController,
            builder: (context, selectedMessages, child) {
              return selectedMessages.isNotEmpty
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.forward),
                            onPressed: () {
                              selectedController.value
                                  .map((e) => e.text)
                                  .toList()
                                  .log('Selected messages');
                            }),
                        IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deleteAll();
                            }),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              deselectAll();
                            }),
                      ],
                    )
                  : const SizedBox.shrink();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String item) {
              if (item == 'upload_file') {
                ChatService.instance.updateSenderInfo(
                  userId: widget.user1,
                  imageUrl: 'https://picsum.photos/200/300',
                );
              }
              if (item == 'update_name') {
                ChatService.instance.updateSenderInfo(
                  userId: widget.user1,
                  name: 'Aswin Loki',
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                  value: 'update_name', child: Text('Update Name')),
              const PopupMenuItem<String>(
                  value: 'upload_file', child: Text('Upload Profile Image')),
            ],
          ),
        ],
      ),
      body: ChatScreen(
        backgroundColor: Colors.amber,
        enableSwipeToDelete: false,
        backgroundImage: DecorationImage(
          image: NetworkImage('https://picsum.photos/400/800'),
          fit: BoxFit.fitWidth,
        ),
        onMessageSelected: (messages, deselectAll, deleteAll) {
          selectedController.value = messages;
          this.deselectAll = deselectAll;
          this.deleteAll = deleteAll;
        },
        getLastSeen: (lastSeen) {
          _lastSeen.value = lastSeen.log('Last seen');
        },
        mediaUploaderFunction: (mediaPath) async {
          return uploadMediaFile(
              mediaPath, 'https://api.escuelajs.co/api/v1/files/upload');
        },
        intialChatLimit: 15,
        senderId: widget.user1,
        receiverId: widget.user2,
        messageBubbleBuilder: ({required isMe, required message}) {
          return MessageBubble(isMe: isMe, message: message);
        },
        enableTypingStatus: true,
        typingIdicationBuilder: () => TypingIndicator(),
        sendMessageBuilder: (
          context, {
          required sendMediaMessage,
          required sendMessage,
          onTypingMessage,
        }) {
          return Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey,
              ),
            ),
            child: Row(
              children: [
                ImagePickerWidget(
                  onImagePicked: (path) {
                    sendMediaMessage(path, MessageType.image);
                  },
                ),
                Expanded(
                  child: TextField(
                    onChanged: onTypingMessage,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Type a message",
                    ),
                    controller: textEditingController,
                    onSubmitted: (value) {
                      sendMessage(value);
                      textEditingController.clear();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ValueListenableBuilder(
                    valueListenable: textEditingController,
                    builder: (context, value, child) {
                      if (value.text.isNotEmpty) {
                        return GestureDetector(
                          onTap: () {
                            sendMessage(textEditingController.text);
                            textEditingController.clear();
                          },
                          onLongPressStart: (_) async {
                            // runs every 1 second
                            timer =
                                Timer.periodic(Duration(seconds: 1), (timer) {
                              sendMessage('tick: ${timer.tick.toString()}');
                            });
                          },
                          onLongPressEnd: (_) {
                            // cancel the timer
                            timer?.cancel();
                            timer = null;
                          },
                          child: const Icon(Icons.send),
                        );
                      } else {
                        return AudioRecorderWidget(
                          onStop: (path) {
                            sendMediaMessage(path, MessageType.voice);
                          },
                        );
                      }
                    })
              ],
            ),
          );
        },
      ),
    );
  }
}

Future<String> uploadMediaFile(String filePath, String uploadUrl) async {
  final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
  request.files.add(await http.MultipartFile.fromPath('file', filePath));

  final response = await request.send();

  if (response.statusCode == 201) {
    final respStr = await response.stream.bytesToString();
    final data = json.decode(respStr);
    return data['location'].toString().log('Audio file uploaded to: ');
  } else {
    response.statusCode.log('Upload failed with status: ');
    return '';
  }
}
