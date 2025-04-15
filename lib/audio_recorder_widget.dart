import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:path_provider/path_provider.dart';

class AudioRecorderWidget extends StatefulWidget {
  final void Function(String path)? onStop;

  const AudioRecorderWidget({super.key, this.onStop});

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }

  Future<void> _startRecording() async {
    final dir = await getTemporaryDirectory();
    _filePath =
        '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder.startRecorder(toFile: _filePath, codec: Codec.aacADTS);
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() => _isRecording = false);
    if (_filePath != null && widget.onStop != null) {
      widget.onStop!(_filePath!);
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_isRecording ? Icons.stop : Icons.mic),
      color: _isRecording ? Colors.red : Colors.black,
      onPressed: _isRecording ? _stopRecording : _startRecording,
    );
  }
}
