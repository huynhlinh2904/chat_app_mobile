import 'package:flutter/material.dart';

class SoftAvatar extends StatelessWidget {
  const SoftAvatar({
    super.key,
    this.url,
    required this.seed,
    required this.initials,
    this.size = 44,
  });

  final String? url;
  final int seed;
  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bg = _softColor(seed);
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(
        child: url != null
            ? Image.network(
          url!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(bg),
          loadingBuilder: (ctx, child, progress) => progress == null ? child : _fallback(bg),
        )
            : _fallback(bg),
      ),
    );
  }

  Widget _fallback(Color bg) => Container(
    color: bg.withOpacity(0.18),
    alignment: Alignment.center,
    child: Text(
      initials,
      style: TextStyle(fontWeight: FontWeight.w700, color: bg),
    ),
  );

  Color _softColor(int seed) {
    const palette = [
      Color(0xFF7C4DFF),
      Color(0xFF00BFA6),
      Color(0xFF03A9F4),
      Color(0xFFFF7043),
      Color(0xFF8BC34A),
      Color(0xFFEC407A),
      Color(0xFFFFB300),
    ];
    return palette[seed.abs() % palette.length];
  }
}