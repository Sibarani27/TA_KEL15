import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import '../data/model_cabai.dart';
import '../tema.dart';
import 'komponen.dart';
import '../data/penyakit.dart';

class ModeLive extends StatefulWidget {
  const ModeLive({super.key});

  @override
  State<ModeLive> createState() => _ModeLiveState();
}

class _ModeLiveState extends State<ModeLive> {
  final _kontrol = YOLOViewController();
  final _ms = ValueNotifier<double?>(null);
  final _fps = ValueNotifier<double?>(null);
  final _stabil = ValueNotifier<Deteksi?>(null);

  // Hasil teratas dari beberapa frame terakhir, supaya tampilan tidak berkedip
  final List<Deteksi?> _jendela = [];
  static const _ukuranJendela = 8;
  static const _minimalSama = 4;

  DateTime _terakhirUI = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _terakhirMasuk = DateTime.now();
  Timer? _pengawas;

  @override
  void initState() {
    super.initState();
    // Jika tidak ada hasil baru beberapa saat, kosongkan tampilan
    _pengawas = Timer.periodic(const Duration(milliseconds: 600), (_) {
      final lama = DateTime.now().difference(_terakhirMasuk).inMilliseconds;
      if (lama > 1500 && _stabil.value != null) {
        _jendela.clear();
        _stabil.value = null;
      }
    });
  }

  @override
  void dispose() {
    _pengawas?.cancel();
    _kontrol.dispose();
    _ms.dispose();
    _fps.dispose();
    _stabil.dispose();
    super.dispose();
  }

  void _onResult(List<YOLOResult> hasil) {
    _terakhirMasuk = DateTime.now();

        // Hanya hasil yang cukup yakin dan kelasnya dikenal yang dihitung
    final layak = hasil.where(
      (r) =>
          r.confidence >= ambangMinimal &&
          kamusPenyakit[kunciKelas(r.className)] != null,
    );

    Deteksi? atas;
    if (layak.isNotEmpty) {
      final t = layak.reduce((a, b) => a.confidence >= b.confidence ? a : b);
      atas = Deteksi(t.className, t.confidence);
    }
    _jendela.add(atas);
    if (_jendela.length > _ukuranJendela) _jendela.removeAt(0);

    // Perbarui tampilan paling cepat tiap 250 ms
    final sekarang = DateTime.now();
    if (sekarang.difference(_terakhirUI).inMilliseconds < 250) return;
    _terakhirUI = sekarang;
    _stabil.value = _hitungStabil();
  }

  Deteksi? _hitungStabil() {
    final kumpulan = <String, List<double>>{};
    for (final d in _jendela) {
      if (d == null) continue;
      kumpulan.putIfAbsent(d.nama, () => []).add(d.skor);
    }
    String? menang;
    var terbanyak = 0;
    for (final e in kumpulan.entries) {
      if (e.value.length > terbanyak) {
        terbanyak = e.value.length;
        menang = e.key;
      }
    }
    if (menang == null || terbanyak < _minimalSama) return null;
    final skor = kumpulan[menang]!;
    final rata = skor.reduce((a, b) => a + b) / skor.length;
    return Deteksi(menang, rata);
  }

  Widget _lencana(Widget isi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
      ),
      child: isi,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BingkaiBidik(
          isi: YOLOView(
            modelPath: jalurModel,
            controller: _kontrol,
            confidenceThreshold: ambangMinimal,
            onResult: _onResult,
            onPerformanceMetrics: (m) {
              _ms.value = m.processingTimeMs;
              _fps.value = m.fps;
            },
          ),
          atas: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _lencana(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.circle, size: 8, color: Colors.redAccent),
                    SizedBox(width: 6),
                    Text(
                      'Live',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _lencana(
                ValueListenableBuilder<double?>(
                  valueListenable: _ms,
                  builder: (_, ms, __) {
                    final fps = _fps.value;
                    final teks = ms == null
                        ? '...'
                        : '${ms.toStringAsFixed(0)} ms'
                            '${fps == null ? '' : ' | ${fps.toStringAsFixed(0)} fps'}';
                    return Text(
                      teks,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () => _kontrol.switchCamera(),
          icon: const Icon(Icons.flip_camera_android_outlined),
          label: const Text('Ganti kamera'),
          style: gayaSekunder(context),
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<Deteksi?>(
          valueListenable: _stabil,
          builder: (_, d, __) {
            if (d == null) {
              return KartuPesan(
                'Arahkan kamera ke daun atau buah cabai, lalu tahan beberapa detik.',
                warna: p.teksRedup,
              );
            }
            return KartuHasil(hasil: [d], ringkas: true);
          },
        ),
        const SizedBox(height: 10),
        Text(
          'Mode live lebih berat. Jika gambar patah-patah, gunakan mode Foto.',
          style: TextStyle(color: p.teksRedup, fontSize: 12),
        ),
      ],
    );
  }
}