import 'package:flutter/material.dart';
import '../tema.dart';
import '../data/riwayat.dart';

class HalamanHome extends StatelessWidget {
  final void Function(int) pindahTab;
  const HalamanHome({super.key, required this.pindahTab});

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            const SizedBox(height: 20),
            _kartuInfo(context),
            const SizedBox(height: 24),
            Text(
              'Fitur utama',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: p.teksRedup,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _KartuAksi(
                    ikon: Icons.photo_camera_outlined,
                    judul: 'Pindai daun',
                    keterangan: 'Foto atau kamera langsung',
                    utama: true,
                    onTap: () => pindahTab(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _KartuAksi(
                    ikon: Icons.medication_outlined,
                    judul: 'Obat',
                    keterangan: 'Panduan obat pertanian',
                    utama: false,
                    onTap: () => pindahTab(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
    );
  }

  Widget _header(BuildContext context) {
    final p = context.palet;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cek Cabai',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Deteksi penyakit tanaman cabai',
                style: TextStyle(color: p.teksRedup, fontSize: 13),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: p.hijau.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: p.hijau.withValues(alpha: 0.5)),
          ),
          child: Text(
            'Offline',
            style: TextStyle(
              color: p.hijau,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'Tampilan',
          onPressed: () => _bukaPilihanTema(context),
          icon: Icon(Icons.brightness_6_outlined, color: p.teks),
        ),
      ],
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

  Widget _kartuInfo(BuildContext context) {
    final p = context.palet;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.hijau.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.hijau.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: p.hijau, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Model berjalan langsung di HP. Pemeriksaan daun tidak membutuhkan internet.',
              style: TextStyle(height: 1.4, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _KartuAksi extends StatelessWidget {
  final IconData ikon;
  final String judul;
  final String keterangan;
  final bool utama; // true = kartu biru Prussian, false = kartu biasa
  final VoidCallback onTap;

  const _KartuAksi({
    required this.ikon,
    required this.judul,
    required this.keterangan,
    required this.utama,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final latar = utama ? Warna.prussian : p.kartu;
    final warnaTeks = utama ? Colors.white : p.teks;
    final warnaRedup = utama ? Colors.white70 : p.teksRedup;
    final warnaIkon = utama ? Warna.emas : p.hijau;

    return Material(
      color: latar,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 130,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: utama ? Colors.transparent : p.garis),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(ikon, color: warnaIkon, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: warnaTeks,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    keterangan,
                    style: TextStyle(color: warnaRedup, fontSize: 12),
                  ),
                ],
              ),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.garis),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(judul, style: TextStyle(color: p.teksRedup, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            nilai,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}