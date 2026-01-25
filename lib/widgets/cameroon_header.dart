import 'package:flutter/material.dart';

class CameroonHeader extends StatelessWidget {
  final String subtitle;

  const CameroonHeader({
    super.key,
    this.subtitle = 'Plateforme de Gestion des Actes de Naissance',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF007A3D), Color(0xFFCE1126)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      padding: const EdgeInsets.only(top: 60, bottom: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'CAMEROUN',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 16),
              _buildCameroonFlag(),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Paix • Travail • Patrie',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameroonFlag() {
    return Container(
      width: 64,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(color: const Color(0xFF007A3D)),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFCE1126),
              child: const Center(
                child: Icon(
                  Icons.star,
                  color: Color(0xFFFCD116),
                  size: 20,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(color: const Color(0xFFFCD116)),
          ),
        ],
      ),
    );
  }
}
