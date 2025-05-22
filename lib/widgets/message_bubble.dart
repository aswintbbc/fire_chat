import 'dart:async';

import 'package:chaty/models/message.dart';
import 'package:chaty/utils/extensions.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:fire_chat/widgets/audio_widget.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
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
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.type == MessageType.image)
                InkWell(
                  onTap: () {
                    final imageProvider =
                        Image.network(message.mediaUrl!).image;
                    showImageViewer(context, imageProvider);
                  },
                  child: Image.network(
                    message.mediaUrl!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              if (message.type == MessageType.voice)
                SizedBox(
                  width: 250,
                  child: AudioPlayerWidget(
                    audioUrl: message.mediaUrl ?? '',
                    key: ValueKey('voice${message.mediaUrl}'),
                  ),
                ),
              if (message.text.isNotEmpty)
                MessageViewerWidget(message: message),
              const SizedBox(height: 5),
              TimeAgoWidget(message: message),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageViewerWidget extends StatefulWidget {
  const MessageViewerWidget({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  State<MessageViewerWidget> createState() => _MessageViewerWidgetState();
}

class _MessageViewerWidgetState extends State<MessageViewerWidget> {
  PreviewData? previewData;

  @override
  Widget build(BuildContext context) {
    // return widget.message.text.containsUrl()
    //     ? LinkPreview(
    //         enableAnimation: true,
    //         onPreviewDataFetched: (data) {
    //           setState(() {
    //             previewData = data;
    //           });
    //         },
    //         previewData: previewData, // Pass the preview data from the state
    //         text: widget.message.text,
    //         openOnPreviewImageTap: true,
    //         onLinkPressed: (p0) async {
    //           if (!await launchUrl(Uri.parse(previewData?.link ?? ''))) {
    //             // Handle the error if the URL cannot be launched
    //             throw Exception('Could not launch ');
    //           }
    //         },
    //         textWidget: Text(widget.message.text),
    //         width: MediaQuery.of(context).size.width,
    //       )
    //     :
    return SelectableText(widget.message.text);
  }
}

class TimeAgoWidget extends StatefulWidget {
  const TimeAgoWidget({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  State<TimeAgoWidget> createState() => _TimeAgoWidgetState();
}

class _TimeAgoWidgetState extends State<TimeAgoWidget> {
  late Timer timer;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(minutes: 1), (Timer t) => addValue());
  }

  void addValue() {
    setState(() {
      counter++;
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.message.timestamp.toLocal().timeAgo(),
      style: const TextStyle(fontSize: 12),
    );
  }
}

class SampleLoadingChecker extends StatefulWidget {
  const SampleLoadingChecker(
      {super.key, required this.message, required this.isMe});
  final Message message;
  final bool isMe;
  @override
  State<SampleLoadingChecker> createState() => _SampleLoadingCheckerState();
}

class _SampleLoadingCheckerState extends State<SampleLoadingChecker> {
  late Color _color;
  @override
  void initState() {
    _color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
        .withValues(alpha: 1.0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _color,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(widget.message.text.isNotEmpty
            ? widget.message.text
            : widget.message.mediaUrl != null
                ? "Media"
                : "Loading..."),
      ),
    );
  }
}
