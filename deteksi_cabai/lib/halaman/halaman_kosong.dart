import 'package:flutter/material.dart';
import '../tema.dart';

class HalamanKosong extends StatelessWidget {
  final IconData ikon;
  final String judul;
  final String keterangan;

  const HalamanKosong({
    super.key,
    required this.ikon,
    required this.judul,
    required this.keterangan,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(ikon, size: 56, color: p.aksen),
              const SizedBox(height: 16),
              Text(
                judul,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                keterangan,
                textAlign: TextAlign.center,
                style: TextStyle(color: p.teksRedup, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}