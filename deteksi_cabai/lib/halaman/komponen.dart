import 'package:flutter/material.dart';
import '../data/model_cabai.dart';
import '../data/penyakit.dart';
import '../tema.dart';

ButtonStyle gayaUtama(BuildContext c) {
  final p = c.palet;
  final gelap = Theme.of(c).brightness == Brightness.dark;
  return FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(52),
    backgroundColor: p.aksen,
    foregroundColor: gelap ? Colors.black : Colors.white,
    shape: const StadiumBorder(),
    textStyle: const TextStyle(fontWeight: FontWeight.w700),
  );
}

ButtonStyle gayaSekunder(BuildContext c) {
  final p = c.palet;
  return OutlinedButton.styleFrom(
    minimumSize: const Size.fromHeight(52),
    foregroundColor: p.teks,
    side: BorderSide(color: p.teksRedup, width: 1.2),
    shape: const StadiumBorder(),
    textStyle: const TextStyle(fontWeight: FontWeight.w700),
  );
}

// Sudut bingkai ala jendela bidik kamera
class SudutBingkai extends CustomPainter {
  final Color warna;
  SudutBingkai(this.warna);

  @override
  void paint(Canvas canvas, Size size) {
    final cat = Paint()
      ..color = warna
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    const m = 14.0;
    const l = 28.0;
    final w = size.width;
    final h = size.height;

    canvas.drawPath(
        Path()
          ..moveTo(m, m + l)
          ..lineTo(m, m)
          ..lineTo(m + l, m),
        cat);
    canvas.drawPath(
        Path()
          ..moveTo(w - m - l, m)
          ..lineTo(w - m, m)
          ..lineTo(w - m, m + l),
        cat);
    canvas.drawPath(
        Path()
          ..moveTo(m, h - m - l)
          ..lineTo(m, h - m)
          ..lineTo(m + l, h - m),
        cat);
    canvas.drawPath(
        Path()
          ..moveTo(w - m - l, h - m)
          ..lineTo(w - m, h - m)
          ..lineTo(w - m, h - m - l),
        cat);
  }

  @override
  bool shouldRepaint(covariant SudutBingkai old) => old.warna != warna;
}

// Bingkai persegi (1:1) tempat foto atau kamera ditampilkan.
// Latarnya sengaja selalu gelap di mode terang maupun gelap.
class BingkaiBidik extends StatelessWidget {
  final Widget isi;
  final bool sibuk;
  final String teksSibuk;
  final Widget? atas;

  const BingkaiBidik({
    super.key,
    required this.isi,
    this.sibuk = false,
    this.teksSibuk = 'Memeriksa...',
    this.atas,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: const Color(0xFF1E1635)),
            isi,
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: SudutBingkai(Warna.emas)),
              ),
            ),
            if (atas != null)
              Positioned(left: 26, right: 26, top: 26, child: atas!),
            if (sibuk)
              Container(
                color: Colors.black.withValues(alpha: 0.6),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Warna.emas),
                      const SizedBox(height: 12),
                      Text(
                        teksSibuk,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class StatusModel extends StatelessWidget {
  final bool siap;
  final bool gagal;
  const StatusModel({super.key, required this.siap, required this.gagal});

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final warna =
        gagal ? p.merah : (siap ? p.hijau : Colors.orange.shade700);
    final label = gagal
        ? 'Model gagal dimuat'
        : (siap ? 'Model siap, tanpa internet' : 'Memuat model...');
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: warna, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: warna,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class KartuPesan extends StatelessWidget {
  final String isi;
  final Color warna;
  const KartuPesan(this.isi, {super.key, required this.warna});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warna.withValues(alpha: 0.45)),
      ),
      child: Text(isi, style: const TextStyle(height: 1.4)),
    );
  }
}

class KartuHasil extends StatelessWidget {
  final List<Deteksi> hasil; // sudah terurut dari yang paling yakin
  final bool ringkas;
  const KartuHasil({super.key, required this.hasil, this.ringkas = false});

  @override
  Widget build(BuildContext context) {
    final p = context.palet;

    if (hasil.isEmpty) {
      return KartuPesan(
        'Tidak ada daun yang terdeteksi. Coba foto lebih dekat, dengan cahaya cukup dan daun memenuhi bingkai.',
        warna: Colors.orange.shade700,
      );
    }

    final utama = hasil.first;
    final info = utama.info;
    final persen = '${(utama.skor * 100).toStringAsFixed(0)}%';

    if (info == null) {
      return KartuPesan(
        'Tidak ada daun cabai yang terdeteksi. Pastikan yang difoto adalah daun atau buah cabai, dekat, dan cahayanya cukup.',
        warna: Colors.orange.shade700,
      );
    }

    if (utama.skor < ambangYakin) {
      return KartuPesan(
        'Tidak ada daun cabai yang terdeteksi. Pastikan yang difoto adalah daun atau buah cabai, dekat, dan cahayanya cukup.',
        warna: Colors.orange.shade700,
      );
    }

    final warna = info.sehat ? p.hijau : p.merah;

    // Kemungkinan lain, tanpa kelas yang sama dengan hasil utama
    final lain = <String, double>{};
    for (final d in hasil.skip(1)) {
      if (d.nama == utama.nama || lain.containsKey(d.nama)) continue;
      lain[d.nama] = d.skor;
      if (lain.length == 3) break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.kartu,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: warna.withValues(alpha: 0.5), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            info.nama,
            style: TextStyle(
              fontSize: ringkas ? 20 : 24,
              fontWeight: FontWeight.w800,
              color: warna,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: utama.skor.clamp(0.0, 1.0),
                    minHeight: 8,
                    color: warna,
                    backgroundColor: warna.withValues(alpha: 0.18),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$persen yakin',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          if (!ringkas) ...[
            const SizedBox(height: 16),
            _Baris('Ciri yang tampak', info.ciri),
            const SizedBox(height: 12),
            _Baris('Yang bisa dilakukan', info.saran),
            if (lain.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Terdeteksi juga: ${lain.entries.map((e) => '${kamusPenyakit[kunciKelas(e.key)]?.nama ?? e.key} (${(e.value * 100).toStringAsFixed(0)}%)').join(', ')}',
                style: TextStyle(color: p.teksRedup, fontSize: 13),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              'Hasil ini bantuan awal, bukan diagnosis pasti. Pastikan ke penyuluh pertanian sebelum mengambil tindakan.',
              style: TextStyle(color: p.teksRedup, fontSize: 12, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class _Baris extends StatelessWidget {
  final String judul;
  final String isi;
  const _Baris(this.judul, this.isi);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          judul,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 3),
        Text(isi, style: const TextStyle(height: 1.4)),
      ],
    );
  }
}