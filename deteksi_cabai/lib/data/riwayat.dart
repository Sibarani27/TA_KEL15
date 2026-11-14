import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'model_cabai.dart';
import 'penyakit.dart';

const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String formatWaktu(DateTime w) {
  final jam = w.hour.toString().padLeft(2, '0');
  final mnt = w.minute.toString().padLeft(2, '0');
  return '${w.day} ${_bulan[w.month - 1]} ${w.year}, $jam:$mnt';
}

class Pemeriksaan {
  final int? id;
  final DateTime waktu;
  final String kelas;
  final double skor;
  final String lahan;
  final String? fotoPath;
  final double? ms;

  const Pemeriksaan({
    this.id,
    required this.waktu,
    required this.kelas,
    required this.skor,
    required this.lahan,
    this.fotoPath,
    this.ms,
  });

  Penyakit? get info => kamusPenyakit[kunciKelas(kelas)];
  String get nama => info?.nama ?? kelas;

  Map<String, Object?> toMap() => {
        'waktu': waktu.millisecondsSinceEpoch,
        'kelas': kelas,
        'skor': skor,
        'lahan': lahan,
        'foto_path': fotoPath,
        'ms': ms,
      };

  factory Pemeriksaan.dariMap(Map<String, Object?> m) => Pemeriksaan(
        id: m['id'] as int?,
        waktu: DateTime.fromMillisecondsSinceEpoch(m['waktu'] as int),
        kelas: m['kelas'] as String,
        skor: (m['skor'] as num).toDouble(),
        lahan: (m['lahan'] as String?) ?? '',
        fotoPath: m['foto_path'] as String?,
        ms: (m['ms'] as num?)?.toDouble(),
      );
}

class RepoRiwayat extends ChangeNotifier {
  Database? _db;
  List<Pemeriksaan> _daftar = [];
  String lahanTerakhir = '';

  List<Pemeriksaan> get daftar => List.unmodifiable(_daftar);
  int get jumlah => _daftar.length;

  double? get rataMs {
    final nilai = _daftar.map((e) => e.ms).whereType<double>().toList();
    if (nilai.isEmpty) return null;
    return nilai.reduce((a, b) => a + b) / nilai.length;
  }

  Future<void> muat() async {
    try {
      final dir = await getDatabasesPath();
      _db = await openDatabase(
        '$dir/riwayat.db',
        version: 1,
        onCreate: (db, versi) => db.execute('''
          CREATE TABLE pemeriksaan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            waktu INTEGER NOT NULL,
            kelas TEXT NOT NULL,
            skor REAL NOT NULL,
            lahan TEXT NOT NULL DEFAULT '',
            foto_path TEXT,
            ms REAL
          )
        '''),
      );
      final baris = await _db!.query('pemeriksaan', orderBy: 'waktu DESC');
      _daftar = baris.map(Pemeriksaan.dariMap).toList();
    } catch (e) {
      debugPrint('Gagal membuka riwayat: $e');
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      lahanTerakhir = prefs.getString('lahan_terakhir') ?? '';
    } catch (_) {}
    notifyListeners();
  }

  Future<bool> simpan({
    required Deteksi hasil,
    required Uint8List foto,
    required String lahan,
    double? ms,
  }) async {
    final db = _db;
    if (db == null) return false;
    try {
      final dok = await getApplicationDocumentsDirectory();
      final folder = Directory('${dok.path}/riwayat');
      if (!await folder.exists()) await folder.create(recursive: true);

      final waktu = DateTime.now();
      final berkas = File('${folder.path}/${waktu.millisecondsSinceEpoch}.jpg');
      await berkas.writeAsBytes(foto);

      final baru = Pemeriksaan(
        waktu: waktu,
        kelas: hasil.nama,
        skor: hasil.skor,
        lahan: lahan,
        fotoPath: berkas.path,
        ms: ms,
      );
      final id = await db.insert('pemeriksaan', baru.toMap());
      _daftar.insert(
        0,
        Pemeriksaan(
          id: id,
          waktu: waktu,
          kelas: baru.kelas,
          skor: baru.skor,
          lahan: lahan,
          fotoPath: berkas.path,
          ms: ms,
        ),
      );

      lahanTerakhir = lahan;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('lahan_terakhir', lahan);
      } catch (_) {}

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Gagal menyimpan riwayat: $e');
      return false;
    }
  }

  Future<void> hapus(Pemeriksaan p) async {
    final db = _db;
    if (db == null || p.id == null) return;
    try {
      await db.delete('pemeriksaan', where: 'id = ?', whereArgs: [p.id]);
      final path = p.fotoPath;
      if (path != null) {
        final f = File(path);
        if (await f.exists()) await f.delete();
      }
      _daftar.removeWhere((e) => e.id == p.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal menghapus riwayat: $e');
    }
  }
}

final riwayat = RepoRiwayat();