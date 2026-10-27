import 'package:flutter/material.dart';

/// Encabezado del menú público: flecha de volver, logo y el título "Menu".
class MenuHeader extends StatelessWidget {
  final String logoAssetPath;
  const MenuHeader({super.key, required this.logoAssetPath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 24, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.subdirectory_arrow_left, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Image.asset(
                  logoAssetPath,
                  height: 56,
                  errorBuilder: (_, __, ___) => const Icon(Icons.house, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 14),
                const Flexible(
                  child: Text('Menu', overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 28, fontFamily: 'serif')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}