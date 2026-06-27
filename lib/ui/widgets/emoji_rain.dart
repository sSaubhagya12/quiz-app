import 'dart:math';
import 'package:flutter/material.dart';

class _EmojiParticle {
  String emoji;
  double x;
  double y;
  double speed;
  double size;
  double wobbleFreq;
  double wobbleAmp;

  _EmojiParticle({
    required this.emoji,
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.wobbleFreq,
    required this.wobbleAmp,
  });
}

class EmojiRain extends StatefulWidget {
  final List<String> emojis;
  final int count;

  const EmojiRain({
    super.key,
    required this.emojis,
    this.count = 20,
  });

  @override
  State<EmojiRain> createState() => _EmojiRainState();
}

class _EmojiRainState extends State<EmojiRain> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<_EmojiParticle> _particles;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(
      widget.count,
      (i) => _newParticle(startOffscreen: i % 2 == 0),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  _EmojiParticle _newParticle({bool startOffscreen = false}) {
    return _EmojiParticle(
      emoji: widget.emojis[_rng.nextInt(widget.emojis.length)],
      x: _rng.nextDouble(),
      y: startOffscreen ? -_rng.nextDouble() * 1.5 : _rng.nextDouble(),
      speed: 0.006 + _rng.nextDouble() * 0.008,
      size: 22 + _rng.nextDouble() * 20,
      wobbleFreq: 1 + _rng.nextDouble() * 3,
      wobbleAmp: 0.015 + _rng.nextDouble() * 0.02,
    );
  }

  void _resetParticle(_EmojiParticle p) {
    p.emoji = widget.emojis[_rng.nextInt(widget.emojis.length)];
    p.x = _rng.nextDouble();
    p.y = -_rng.nextDouble() * 0.5;
    p.speed = 0.006 + _rng.nextDouble() * 0.008;
    p.size = 22 + _rng.nextDouble() * 20;
    p.wobbleFreq = 1 + _rng.nextDouble() * 3;
    p.wobbleAmp = 0.015 + _rng.nextDouble() * 0.02;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Update each particle position
        for (final p in _particles) {
          p.y += p.speed;
          if (p.y > 1.15) {
            _resetParticle(p);
          }
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: _particles.map((p) {
                final wobbleX =
                    p.x + sin(_controller.value * 2 * pi * p.wobbleFreq) * p.wobbleAmp;
                final clampedX = wobbleX.clamp(0.0, 0.95);
                return Positioned(
                  left: clampedX * constraints.maxWidth,
                  top: p.y * constraints.maxHeight,
                  child: Text(
                    p.emoji,
                    style: TextStyle(fontSize: p.size),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}
