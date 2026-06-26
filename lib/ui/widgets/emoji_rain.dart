import 'dart:math';
import 'package:flutter/material.dart';

class _EmojiParticle {
  final String emoji;
  double x;
  double y;
  final double speed;
  final double size;
  final double wobbleFreq;
  final double wobbleAmp;

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
    _particles = List.generate(widget.count, (_) => _newParticle(startOffscreen: true));
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
      speed: 0.003 + _rng.nextDouble() * 0.004,
      size: 20 + _rng.nextDouble() * 22,
      wobbleFreq: 1 + _rng.nextDouble() * 3,
      wobbleAmp: 0.015 + _rng.nextDouble() * 0.02,
    );
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
        // Update particles
        for (var p in _particles) {
          p.y += p.speed;
          if (p.y > 1.15) {
            final newP = _newParticle(startOffscreen: true);
            p.emoji == newP.emoji; // just reference
            p.x = newP.x;
            p.y = -_rng.nextDouble() * 0.3;
          }
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: _particles.map((p) {
                final wobbleX = p.x + sin(_controller.value * 2 * pi * p.wobbleFreq) * p.wobbleAmp;
                return Positioned(
                  left: wobbleX * constraints.maxWidth,
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
