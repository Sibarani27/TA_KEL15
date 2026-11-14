import 'dart:io';
import 'package:flutter/material.dart';
import '../data/ekspor_pdf.dart';
import '../data/riwayat.dart';
import '../tema.dart';

class HalamanRiwayat extends StatelessWidget {
  const HalamanRiwayat({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: riwayat,
        builder: (context, _) {
          final data = riwayat.daftar;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            itemCount: data.isEmpty ? 2 : data.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) return _Kepala(jumlah: data.length);
              if (data.isEmpty) return const _Kosong();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ItemRiwayat(data: data[i - 1]),
              );
            },
          );
        },
      ),
    );
  }
}

class _Kepala extends StatelessWidget {
  final int jumlah;
  const _Kepala({required this.jumlah});

  Future<void> _ekspor(BuildContext context) async {
    try {
      await bagikanRiwayatPdf(riwayat.daftar);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF gagal dibuat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Riwayat',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  jumlah == 0
                      ? 'Belum ada pemeriksaan'
                      : '$jumlah pemeriksaan tersimpan di HP',
                  style: TextStyle(color: p.teksRedup, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Ekspor PDF',
            onPressed: jumlah == 0 ? null : () => _ekspor(context),
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
        ],
      ),
    );
  }
}

class _Kosong extends StatelessWidget {
  const _Kosong();

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Icon(Icons.history, size: 56, color: p.aksen),
          const SizedBox(height: 16),
          const Text(
            'Belum ada riwayat',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Ambil foto di tab Camera, lalu tekan "Simpan ke riwayat". Hasilnya muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: p.teksRedup, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _Foto extends StatelessWidget {
  final String? path;
  final double ukuran;
  const _Foto({required this.path, required this.ukuran});

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    Widget ikon() => Container(
          color: p.garis,
          child: Icon(Icons.eco_outlined, color: p.teksRedup),
        );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: ukuran,
        height: ukuran,
        child: path == null
            ? ikon()
            : Image.file(
                File(path!),
                fit: BoxFit.cover,
                cacheWidth: (ukuran * 3).round(),
                errorBuilder: (_, __, ___) => ikon(),
              ),
      ),
    );
  }
}

class _ItemRiwayat extends StatelessWidget {
  final Pemeriksaan data;
  const _ItemRiwayat({required this.data});

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final info = data.info;
    final warna = info == null ? p.teksRedup : (info.sehat ? p.hijau : p.merah);

    return Material(
      color: p.kartu,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => _Detail(data: data),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.garis),
          ),
          child: Row(
            children: [
              _Foto(path: data.fotoPath, ukuran: 64),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.nama,
                      style: TextStyle(
                        color: warna,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatWaktu(data.waktu),
                      style: TextStyle(color: p.teksRedup, fontSize: 12),
                    ),
                    Text(
                      data.lahan.isEmpty ? 'Tanpa nama lahan' : data.lahan,
                      style: TextStyle(color: p.teksRedup, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: warna.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(data.skor * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: warna,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  final Pemeriksaan data;
  const _Detail({required this.data});

  Future<void> _hapus(BuildContext context) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus pemeriksaan ini?'),
        content: const Text(
          'Foto dan catatannya dihapus dari HP dan tidak bisa dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ya != true) return;
    await riwayat.hapus(data);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final info = data.info;
    final warna = info == null ? p.teksRedup : (info.sehat ? p.hijau : p.merah);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.fotoPath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 260,
                width: double.infinity,
                color: const Color(0xFF0A1118),
                child: Image.file(
                  File(data.fotoPath!),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image_outlined,
                        color: Colors.white38, size: 40),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            data.nama,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: warna,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(data.skor * 100).toStringAsFixed(0)}% yakin',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${formatWaktu(data.waktu)}'
            '${data.lahan.isEmpty ? '' : '\nLahan: ${data.lahan}'}',
            style: TextStyle(color: p.teksRedup, height: 1.4),
          ),
          if (info != null) ...[
            const SizedBox(height: 16),
            const Text('Ciri yang tampak',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(info.ciri, style: const TextStyle(height: 1.4)),
            const SizedBox(height: 12),
            const Text('Yang bisa dilakukan',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(info.saran, style: const TextStyle(height: 1.4)),
          ],
          const SizedBox(height: 12),
          Text(
            'Hasil ini bantuan awal, bukan diagnosis pasti.',
            style: TextStyle(color: p.teksRedup, fontSize: 12),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _hapus(context),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Hapus pemeriksaan ini'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: p.merah,
                side: BorderSide(color: p.merah),
                shape: const StadiumBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}