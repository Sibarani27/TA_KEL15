import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/penyakit.dart';
import '../data/riwayat.dart';
import '../tema.dart';

class HalamanHome extends StatelessWidget {
  final void Function(int) pindahTab;
  const HalamanHome({super.key, required this.pindahTab});

  static const _kunciInfo = [
    'antraknosa',
    'virus_keriting',
    'virus_kuning',
    'daun_sehat',
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final info = [
      for (final k in _kunciInfo)
        if (kamusPenyakit[k] != null) kamusPenyakit[k]!,
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kartuDeteksi(context),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Informasi Penyakit',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => pindahTab(2),
                        child: Text(
                          'Lihat obat',
                          style: TextStyle(
                            color: p.aksen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.15,
                    children: [
                      for (final i in info)
                        _KartuPenyakit(info: i, onTap: () => pindahTab(2)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _kartuTips(context),
                  const SizedBox(height: 22),
                  Text(
                    'Ringkasan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: p.teksRedup,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListenableBuilder(
                    listenable: riwayat,
                    builder: (context, _) {
                      final rata = riwayat.rataMs;
                      return Row(
                        children: [
                          Expanded(
                            child: _Statistik(
                              judul: 'Pindaian tersimpan',
                              nilai: '${riwayat.jumlah}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _Statistik(
                              judul: 'Rata-rata proses',
                              nilai: rata == null
                                  ? '-'
                                  : '${rata.toStringAsFixed(0)} ms',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final atas = MediaQuery.of(context).padding.top;
    return ClipPath(
      clipper: _Gelombang(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20, atas + 16, 12, 46),
        decoration: BoxDecoration(gradient: gradienUngu(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.eco_outlined, color: Warna.unguTua),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Cek Cabai',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 3.5,
                        backgroundColor: Color(0xFF7CE3A1),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Offline',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Tampilan',
                  onPressed: () => _bukaPilihanTema(context),
                  icon: const Icon(
                    Icons.brightness_6_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Deteksi penyakit tanaman cabai lebih mudah dan cepat. '
              'Model berjalan langsung di HP, tanpa internet.',
              style: TextStyle(
                color: Color(0xFFEFE8FF),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kartuDeteksi(BuildContext context) {
    final p = context.palet;
    final gelap = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: p.kartu,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () => pindahTab(1),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: p.garis),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: p.aksen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.document_scanner_outlined,
                  size: 30,
                  color: gelap ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deteksi Sekarang',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Ambil atau pilih foto daun cabai, atau pakai mode live.',
                      style: TextStyle(
                        color: p.teksRedup,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: p.aksenMuda,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward, size: 18, color: p.aksen),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kartuTips(BuildContext context) {
    final p = context.palet;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.aksenMuda,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: p.kartu,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lightbulb_outline, color: p.aksen, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Perawatan',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                SizedBox(height: 2),
                Text(
                  'Periksa daun secara rutin dan hindari kelembapan berlebih.',
                  style: TextStyle(fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _bukaPilihanTema(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ValueListenableBuilder<ThemeMode>(
        valueListenable: kontrolTema,
        builder: (context, mode, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tampilan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.phone_android),
                        label: Text('Sistem'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Terang'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Gelap'),
                      ),
                    ],
                    selected: {mode},
                    onSelectionChanged: (s) => kontrolTema.atur(s.first),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Sistem mengikuti pengaturan tema di HP-mu.',
                  style: TextStyle(
                    color: context.palet.teksRedup,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Gelombang extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final w = s.width;
    final h = s.height;
    return Path()
      ..lineTo(0, h - 24)
      ..quadraticBezierTo(w * 0.25, h + 4, w * 0.55, h - 16)
      ..quadraticBezierTo(w * 0.85, h - 34, w, h - 12)
      ..lineTo(w, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

class _KartuPenyakit extends StatelessWidget {
  final Penyakit info;
  final VoidCallback onTap;
  const _KartuPenyakit({required this.info, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final warna = info.sehat ? p.hijau : p.merah;
    return Material(
      color: p.kartu,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.garis),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: warna.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    info.sehat ? Icons.eco_outlined : Icons.warning_amber_rounded,
                    color: warna,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                info.nama,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _Statistik extends StatelessWidget {
  final String judul;
  final String nilai;
  const _Statistik({required this.judul, required this.nilai});

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.kartu,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.garis),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(judul, style: TextStyle(color: p.teksRedup, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            nilai,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}