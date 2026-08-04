import 'package:flutter/material.dart';

class TrastornadoresHeaderLogo extends StatelessWidget {
  final double fontSize;

  const TrastornadoresHeaderLogo({super.key, this.fontSize = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Golden Cross Graphic
        Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.add, size: fontSize * 1.6, color: const Color(0xFFFFC107)),
            Icon(Icons.add, size: fontSize * 1.4, color: Colors.amberAccent),
          ],
        ),
        const SizedBox(width: 6),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MINISTERIO DE JESÚS',
              style: TextStyle(
                fontSize: fontSize * 0.55,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
                letterSpacing: 1.2,
                height: 1.0,
              ),
            ),
            Text(
              'TRASTORNADORES',
              style: TextStyle(
                fontSize: fontSize * 1.1,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.0,
                height: 1.1,
              ),
            ),
            Text(
              'VISIÓN CONQUISTADORA',
              style: TextStyle(
                fontSize: fontSize * 0.45,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFFFC107),
                letterSpacing: 1.5,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TrastornadoresBadgeLogo extends StatelessWidget {
  final double size;

  const TrastornadoresBadgeLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.transparent, // Sin fondo (transparente) como fue solicitado
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Globe background aura effect
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.lightBlueAccent.withOpacity(0.4),
                  const Color(0xFF0038A8).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Central Cross & Family Silhouette representation
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add, // Golden Cross
                size: 38,
                color: Color(0xFFFFC107),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.person, size: 22, color: Colors.white),
                  Icon(Icons.child_care, size: 16, color: Colors.white70),
                  Icon(Icons.person_outline, size: 20, color: Colors.white),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
