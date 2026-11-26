import 'package:flutter/material.dart';
import '../data/obat.dart';
import '../data/penyakit.dart';
import '../tema.dart';
import 'komponen.dart';

class HalamanObat extends StatefulWidget {
  final String? filterAwal; // kunci penyakit dari Home, null = semua
  const HalamanObat({super.key, this.filterAwal});

  @override
  State<HalamanObat> createState() => _HalamanObatState();
}

class _HalamanObatState extends State<HalamanObat> {
  late final Future<DaftarObat> _data = muatObat();
  final _cari = TextEditingController();
    late String? _filter = widget.filterAwal; // null = semua penyakit

  @override
  void dispose() {
    _cari.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final kunciFilter =
        kamusPenyakit.keys.where((k) => k != 'daun_sehat').toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Obat',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Panduan pengendalian hama dan penyakit, tanpa internet.',
              style: TextStyle(color: p.teksRedup, fontSize: 13),
            ),
            const SizedBox(height: 16),
            FutureBuilder<DaftarObat>(
              future: _data,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError) {
                  return KartuPesan(
                    'Data obat gagal dimuat: ${snap.error}. Pastikan assets/data/ sudah didaftarkan di pubspec.yaml.',
                    warna: p.merah,
                  );
                }

                final data = snap.data!;
                final hasil = data.obat
                    .where((o) =>
                        o.cocok(_cari.text) &&
                        (_filter == null || o.target.contains(_filter)))
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data.draf && data.catatan != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline,
                                size: 20, color: Colors.orange.shade700),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                data.catatan!,
                                style: const TextStyle(
                                    fontSize: 13, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextField(
                      controller: _cari,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Cari obat, bahan aktif, atau penyakit',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _cari.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => setState(_cari.clear),
                              ),
                        filled: true,
                        fillColor: p.kartu,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: p.garis),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: p.garis),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _Pilihan(
                            label: 'Semua',
                            aktif: _filter == null,
                            onTap: () => setState(() => _filter = null),
                          ),
                          for (final k in kunciFilter)
                            _Pilihan(
                              label: kamusPenyakit[k]!.nama,
                              aktif: _filter == k,
                              onTap: () => setState(() => _filter = k),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (hasil.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Center(
                          child: Text(
                            'Tidak ada hasil. Coba kata kunci lain atau pilih "Semua".',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: p.teksRedup),
                          ),
                        ),
                      )
                    else
                      for (final o in hasil)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _KartuObat(obat: o),
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
}

class _Pilihan extends StatelessWidget {
  final String label;
  final bool aktif;
  final VoidCallback onTap;
  const _Pilihan({
    required this.label,
    required this.aktif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: aktif,
        showCheckmark: false,
        selectedColor: p.aksen.withValues(alpha: 0.18),
        side: BorderSide(color: aktif ? p.aksen : p.garis),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _KartuObat extends StatelessWidget {
  final Obat obat;
  const _KartuObat({required this.obat});

  Widget _lencana(String teks, Color warna) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        teks,
        style: TextStyle(
          color: warna,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final draf = Colors.orange.shade700;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.kartu,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.garis),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  obat.nama,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _lencana(obat.jenis, p.aksen),
            ],
          ),
          if (obat.bahanAktif != null) ...[
            const SizedBox(height: 4),
            Text(
              'Bahan aktif: ${obat.bahanAktif}',
              style: TextStyle(color: p.teksRedup, fontSize: 13),
            ),
          ],
          if (obat.merek.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Merek: ${obat.merek.join(', ')}',
              style: TextStyle(color: p.teksRedup, fontSize: 13),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final k in obat.target)
                _lencana(
                  kamusPenyakit[k]?.nama ?? k,
                  (kamusPenyakit[k]?.sehat ?? false) ? p.hijau : p.merah,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            obat.dosis == null
                ? 'Dosis: ikuti label produk dan arahan penyuluh'
                : 'Dosis: ${obat.dosis}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          if (obat.catatan != null) ...[
            const SizedBox(height: 6),
            Text(
              obat.catatan!,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _lencana(
                obat.terverifikasi ? 'Terverifikasi' : 'DRAF',
                obat.terverifikasi ? p.hijau : draf,
              ),
              if (obat.sumber != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sumber: ${obat.sumber}',
                    style: TextStyle(color: p.teksRedup, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}