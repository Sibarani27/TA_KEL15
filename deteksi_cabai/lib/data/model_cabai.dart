import 'dart:typed_data';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'penyakit.dart';

const jalurModel = 'assets/models/model_cabai.tflite';

/// Di bawah angka ini aplikasi menjawab "belum yakin", bukan memaksa menjawab.
const ambangYakin = 0.4;

class Deteksi {
  final String nama;
  final double skor;
  const Deteksi(this.nama, this.skor);

  Penyakit? get info => kamusPenyakit[kunciKelas(nama)];
}

class HasilFoto {
  final List<Deteksi> deteksi;
  final Uint8List? gambarAnotasi;
  final double? ms;
  const HasilFoto(this.deteksi, this.gambarAnotasi, this.ms);
}

/// Membaca hasil YOLO.predict(). Dibuat berlapis karena nama field
/// bisa berbeda antarversi paket.
HasilFoto bacaHasilFoto(Map<String, dynamic> out) {
  var daftar = <Deteksi>[];
  Uint8List? gambar;
  double? ms;

  try {
    final r = YOLODetectionResults.fromMap(out);
    daftar = [
      for (final d in r.detections) Deteksi(d.className, d.confidence),
    ];
    gambar = r.annotatedImage;
    ms = r.processingTimeMs;
  } catch (_) {
    // lanjut ke pembacaan manual di bawah
  }

  if (daftar.isEmpty) {
    final mentah = out['detections'] ?? out['boxes'];
    if (mentah is List) {
      for (final b in mentah) {
        if (b is Map) {
          final nama =
              (b['className'] ?? b['class'] ?? b['label'] ?? '').toString();
          final skor = (b['confidence'] as num?)?.toDouble() ?? 0.0;
          if (nama.isNotEmpty) daftar.add(Deteksi(nama, skor));
        }
      }
    }
  }

  if (gambar == null && out['annotatedImage'] is Uint8List) {
    gambar = out['annotatedImage'] as Uint8List;
  }
  ms ??= (out['processingTimeMs'] as num?)?.toDouble();

  daftar.sort((a, b) => b.skor.compareTo(a.skor));
  return HasilFoto(daftar, gambar, ms);
}