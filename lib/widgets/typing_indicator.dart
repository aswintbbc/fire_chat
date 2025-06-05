import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<Offset>> _dotAnimations;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _dotAnimations = [
      _createDotAnimation(startDelay: 0.0),
      _createDotAnimation(startDelay: 0.2),
      _createDotAnimation(startDelay: 0.4),
    ];
  }

  Animation<Offset> _createDotAnimation({required double startDelay}) {
    return TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, -0.5),
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, -0.5),
          end: const Offset(0, 0),
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(startDelay, startDelay + 0.6),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(Animation<Offset> animation) {
    return SlideTransition(
      position: animation,
      child: Container(
        width: 4,
        height: 4,
        margin: EdgeInsets.symmetric(horizontal: 2),
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsetsDirectional.only(
        start: 16,
      ),
      alignment: Alignment.center,
      height: 28,
      width: 40,
      padding: EdgeInsets.symmetric(
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8).copyWith(
          topLeft: Radius.circular(0),
        ),
        color: Colors.green,
        border: Border.all(
          width: 1,
          color: Colors.red,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _dotAnimations.map(_buildDot).toList(),
      ),
    );
  }
}
