import 'package:flutter/material.dart';

class PulsingAvatar extends StatefulWidget {
  final String imagePath;
  final bool isOnline;

  const PulsingAvatar({
    super.key,
    required this.imagePath,
    this.isOnline = true,
  });

  @override
  State<PulsingAvatar> createState() => _PulsingAvatarState();
}

class _PulsingAvatarState extends State<PulsingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const int pulseCount = 3;
  static const Duration pulseDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: pulseDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPulse(int index) {
    final double start = index / pulseCount;

    return Center( // Ajout d'un Center pour chaque pulse
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double t = (_controller.value - start);
          if (t < 0) t += 1;

          double progress = (t / (1 / pulseCount)).clamp(0.0, 1.0);
          double size = 44 + 40 * progress;
          double opacity = (1.0 - progress).clamp(0.0, 1.0);

          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // ignore: deprecated_member_use
              color: Colors.green.withOpacity(opacity * 0.3),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
    
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center, 
        children: [
          // Cercles pulsants
          for (int i = 0; i < pulseCount; i++) _buildPulse(i),

          // Avatar centré
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage(widget.imagePath),
            ),
          ),

        
           
        ],
      ),
    );
  }
}