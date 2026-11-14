import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'riwayat.dart';

/// Membuat PDF di HP (tanpa internet), lalu membuka menu bagikan/simpan.
Future<void> bagikanRiwayatPdf(List<Pemeriksaan> daftar) async {
  final dok = pw.Document(title: 'Riwayat Pemeriksaan Cek Cabai');
  final dicetak = formatWaktu(DateTime.now());

  pw.Widget sel(String teks, {bool tebal = false}) => pw.Padding(
        padding: const pw.EdgeInsets.all(5),
        child: pw.Text(
          teks,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: tebal ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      );

  dok.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (ctx) => [
        pw.Text(
          'Riwayat Pemeriksaan Cek Cabai',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Dicetak: $dicetak. Jumlah: ${daftar.length} pemeriksaan.',
          style: pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          columnWidths: {
            0: pw.FixedColumnWidth(26),
            1: pw.FlexColumnWidth(2.2),
            2: pw.FlexColumnWidth(2.4),
            3: pw.FlexColumnWidth(2.4),
            4: pw.FixedColumnWidth(48),
          },
          children: [
            pw.TableRow(
              repeat: true,
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                sel('No', tebal: true),
                sel('Waktu', tebal: true),
                sel('Hasil', tebal: true),
                sel('Lahan', tebal: true),
                sel('Yakin', tebal: true),
              ],
            ),
            for (var i = 0; i < daftar.length; i++)
              pw.TableRow(
                children: [
                  sel('${i + 1}'),
                  sel(formatWaktu(daftar[i].waktu)),
                  sel(daftar[i].nama),
                  sel(daftar[i].lahan.isEmpty ? '-' : daftar[i].lahan),
                  sel('${(daftar[i].skor * 100).toStringAsFixed(0)}%'),
                ],
              ),
          ],
        ),
        pw.SizedBox(height: 14),
        pw.Text(
          'Catatan: hasil deteksi adalah bantuan awal dari model komputer, bukan diagnosis pasti. Konfirmasi ke penyuluh pertanian sebelum mengambil tindakan.',
          style: pw.TextStyle(fontSize: 8),
        ),
      ],
    ),
  );

  final bytes = await dok.save();
  await Printing.sharePdf(bytes: bytes, filename: 'riwayat_cek_cabai.pdf');
}