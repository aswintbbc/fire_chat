import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({super.key, required this.audioUrl});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  double _speed = 1.0;
  final List<double> _speeds = [1.0, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    await _player.setUrl(widget.audioUrl);
    _duration = _player.duration ?? Duration.zero;

    _player.positionStream.listen((pos) {
      setState(() {
        _position = pos;
      });
    });

    _player.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });

      if (state.processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
        setState(() {
          _position = Duration.zero;
        });
      }
    });
  }

  void _togglePlayPause() {
    _isPlaying ? _player.pause() : _player.play();
  }

  void _changeSpeed() {
    int nextIndex = (_speeds.indexOf(_speed) + 1) % _speeds.length;
    _speed = _speeds[nextIndex];
    _player.setSpeed(_speed);
    setState(() {});
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double maxPosition = _duration.inMilliseconds.toDouble();
    final double currentPosition =
        _position.inMilliseconds.clamp(0, maxPosition).toDouble();

    return Row(
      children: [
        IconButton(
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: _togglePlayPause,
        ),
        Expanded(
          child: Slider(
            value: currentPosition,
            max: maxPosition,
            onChanged: (value) {
              _player.seek(Duration(milliseconds: value.toInt()));
            },
          ),
        ),
        TextButton(
          onPressed: _changeSpeed,
          child: Text('${_speed}x'),
        ),
      ],
    );
  }
}
