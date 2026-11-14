import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import '../data/model_cabai.dart';
import '../data/riwayat.dart';
import '../tema.dart';
import 'dialog_lahan.dart';
import 'komponen.dart';

class ModeFoto extends StatefulWidget {
  const ModeFoto({super.key});

  @override
  State<ModeFoto> createState() => _ModeFotoState();
}

class _ModeFotoState extends State<ModeFoto> {
  final _yolo = YOLO(
    modelPath: jalurModel,
    // task: YOLOTask.segment, // aktifkan jika task tidak terbaca otomatis
  );
  final _picker = ImagePicker();

  bool _siap = false;
  bool _sibuk = false;
  bool _tersimpan = false;
  String? _pesan;
  Uint8List? _gambar;
  HasilFoto? _hasil;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void dispose() {
    _yolo.dispose();
    super.dispose();
  }

  Future<void> _muat() async {
    try {
      await _yolo.loadModel();
      if (mounted) setState(() => _siap = true);
    } catch (e) {
      if (mounted) setState(() => _pesan = 'Model gagal dimuat: $e');
    }
  }

  Future<void> _periksa(ImageSource sumber) async {
    try {
      final file = await _picker.pickImage(source: sumber, maxWidth: 1280);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;

      setState(() {
        _gambar = bytes;
        _hasil = null;
        _pesan = null;
        _tersimpan = false;
        _sibuk = true;
      });

      final out = await _yolo.predict(bytes, confidenceThreshold: 0.25);
      debugPrint('Hasil mentah: $out');

      if (!mounted) return;
      setState(() {
        _hasil = bacaHasilFoto(out);
        _sibuk = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pesan = 'Foto tidak bisa diproses: $e';
        _sibuk = false;
      });
    }
  }

  Future<void> _simpan() async {
    final hasil = _hasil;
    final foto = _gambar;
    if (hasil == null || foto == null || hasil.deteksi.isEmpty) return;

    final lahan = await mintaNamaLahan(context, riwayat.lahanTerakhir);
    if (lahan == null || !mounted) return;

    final ok = await riwayat.simpan(
      hasil: hasil.deteksi.first,
      foto: foto,
      lahan: lahan,
      ms: hasil.ms,
    );
    if (!mounted) return;
    if (ok) setState(() => _tersimpan = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Tersimpan di riwayat.' : 'Gagal menyimpan. Coba lagi.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final tampil = _hasil?.gambarAnotasi ?? _gambar;
    final aktif = _siap && !_sibuk;
    final gagal = !_siap && _pesan != null;
    final bisaSimpan = _hasil != null && _hasil!.deteksi.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BingkaiBidik(
          sibuk: _sibuk,
          teksSibuk: 'Memeriksa daun...',
          isi: tampil != null
              ? Image.memory(tampil, fit: BoxFit.contain)
              : const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.eco_outlined, size: 48, color: Colors.white38),
                      SizedBox(height: 8),
                      Text(
                        'Belum ada foto',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 12),
        StatusModel(siap: _siap, gagal: gagal),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: aktif ? () => _periksa(ImageSource.camera) : null,
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Ambil foto'),
                style: gayaUtama(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: aktif ? () => _periksa(ImageSource.gallery) : null,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Dari galeri'),
                style: gayaSekunder(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_pesan != null)
          KartuPesan(_pesan!, warna: p.merah)
        else if (_hasil != null) ...[
          KartuHasil(hasil: _hasil!.deteksi),
          if (_hasil!.ms != null) ...[
            const SizedBox(height: 8),
            Text(
              'Waktu proses: ${_hasil!.ms!.toStringAsFixed(0)} ms',
              style: TextStyle(color: p.teksRedup, fontSize: 12),
            ),
          ],
          if (bisaSimpan) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _tersimpan ? null : _simpan,
              icon: Icon(
                _tersimpan ? Icons.check : Icons.bookmark_add_outlined,
              ),
              label: Text(
                _tersimpan ? 'Tersimpan di riwayat' : 'Simpan ke riwayat',
              ),
              style: gayaSekunder(context),
            ),
          ],
        ],
      ],
    );
  }
}