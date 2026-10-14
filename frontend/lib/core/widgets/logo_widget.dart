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
        Image.asset(
          'assets/images/logo.png',
          height: fontSize * 2.2,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Image.network(
            'assets/logo.png',
            height: fontSize * 2.2,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.church, size: fontSize * 1.6, color: const Color(0xFFFFC107)),
          ),
        ),
        const SizedBox(width: 8),
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

  const TrastornadoresBadgeLogo({super.key, this.size = 270});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Resplandor Suave Dorado/Azul de Silueta
          Image.asset(
            'assets/images/logo.png',
            width: size * 1.03,
            fit: BoxFit.contain,
            color: const Color(0xFFFFC107).withValues(alpha: 0.4),
            colorBlendMode: BlendMode.srcIn,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),

          // 2. Sombra Nítida de Contorno
          Transform.translate(
            offset: const Offset(0, 4),
            child: Image.asset(
              'assets/images/logo.png',
              width: size,
              fit: BoxFit.contain,
              color: const Color(0xFF001F5C).withValues(alpha: 0.15),
              colorBlendMode: BlendMode.srcIn,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),

          // 3. Logo PNG Oficial Limpio y Nítido
          Image.asset(
            'assets/images/logo.png',
            width: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Image.network(
              'assets/logo.png',
              width: size,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
