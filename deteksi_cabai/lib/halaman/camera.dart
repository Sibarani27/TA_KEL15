import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final atas = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, atas + 16, 20, 20),
            decoration: BoxDecoration(
              gradient: gradienUngu(context),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pindai daun',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Foto satu daun yang terlihat jelas, atau arahkan kamera langsung.',
                  style: TextStyle(color: Color(0xFFEFE8FF), fontSize: 13),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (s) => s.contains(WidgetState.selected)
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.18),
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (s) => s.contains(WidgetState.selected)
                            ? Warna.unguTua
                            : Colors.white,
                      ),
                      side: const WidgetStatePropertyAll(BorderSide.none),
                    ),
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
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              // Hanya satu mode yang dibangun, supaya model dan kamera
              // tidak berjalan bersamaan.
              child: _live ? const ModeLive() : const ModeFoto(),
            ),
          ),
        ],
      ),
    );
  }
}