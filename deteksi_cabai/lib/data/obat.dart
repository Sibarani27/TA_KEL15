import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'penyakit.dart';

class Obat {
  final String nama;
  final String jenis;
  final String? bahanAktif;
  final List<String> merek;
  final List<String> target;
  final String? dosis;
  final String? catatan;
  final bool terverifikasi;
  final String? sumber;

  const Obat({
    required this.nama,
    required this.jenis,
    this.bahanAktif,
    this.merek = const [],
    this.target = const [],
    this.dosis,
    this.catatan,
    this.terverifikasi = false,
    this.sumber,
  });

  factory Obat.dariJson(Map<String, dynamic> j) => Obat(
        nama: (j['nama'] ?? '').toString(),
        jenis: (j['jenis'] ?? '').toString(),
        bahanAktif: j['bahan_aktif'] as String?,
        merek: [for (final m in (j['merek'] as List? ?? [])) m.toString()],
        target: [for (final t in (j['target'] as List? ?? [])) t.toString()],
        dosis: j['dosis'] as String?,
        catatan: j['catatan'] as String?,
        terverifikasi: j['verifikasi'] == true,
        sumber: j['sumber'] as String?,
      );

  bool cocok(String cari) {
    final kunci = cari.trim().toLowerCase();
    if (kunci.isEmpty) return true;
    final gudang = [
      nama,
      jenis,
      bahanAktif ?? '',
      ...merek,
      ...target.map((k) => kamusPenyakit[k]?.nama ?? k),
    ].join(' ').toLowerCase();
    return gudang.contains(kunci);
  }
}

class DaftarObat {
  final bool draf;
  final String? catatan;
  final List<Obat> obat;
  const DaftarObat(this.draf, this.catatan, this.obat);
}

Future<DaftarObat> muatObat() async {
  final teks = await rootBundle.loadString('assets/data/obat.json');
  final j = jsonDecode(teks) as Map<String, dynamic>;
  final daftar = [
    for (final o in (j['obat'] as List? ?? []))
      Obat.dariJson(o as Map<String, dynamic>),
  ];
  return DaftarObat(j['draf'] == true, j['catatan'] as String?, daftar);
}