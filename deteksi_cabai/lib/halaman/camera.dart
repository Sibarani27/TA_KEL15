import 'package:flutter/material.dart';
import '../tema.dart';
import 'mode_foto.dart';
import 'mode_live.dart';

class HalamanCamera extends StatefulWidget {
  const HalamanCamera({super.key});

  @override
  State<HalamanCamera> createState() => _HalamanCameraState();
}

class _HalamanCameraState extends State<HalamanCamera> {
  bool _live = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pindai daun',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Foto satu daun yang terlihat jelas, atau arahkan kamera langsung.',
              style: TextStyle(color: p.teksRedup, fontSize: 13),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.photo_camera_outlined),
                    label: Text('Foto'),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.videocam_outlined),
                    label: Text('Live'),
                  ),
                ],
                selected: {_live},
                onSelectionChanged: (s) => setState(() => _live = s.first),
              ),
            ),
            const SizedBox(height: 16),
            // Hanya satu mode yang dibangun, supaya model dan kamera
            // tidak berjalan bersamaan.
            _live ? const ModeLive() : const ModeFoto(),
          ],
        ),
      ),
    );
  }
}