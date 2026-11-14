import 'package:flutter/material.dart';
import 'komponen.dart';

/// Mengembalikan nama lahan (boleh kosong), atau null jika dibatalkan.
Future<String?> mintaNamaLahan(BuildContext context, String awal) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _FormLahan(awal: awal),
  );
}

class _FormLahan extends StatefulWidget {
  final String awal;
  const _FormLahan({required this.awal});

  @override
  State<_FormLahan> createState() => _FormLahanState();
}

class _FormLahanState extends State<_FormLahan> {
  late final TextEditingController _teks =
      TextEditingController(text: widget.awal);

  @override
  void dispose() {
    _teks.dispose();
    super.dispose();
  }

  void _selesai() => Navigator.pop(context, _teks.text.trim());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Simpan ke riwayat',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _teks,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _selesai(),
            decoration: const InputDecoration(
              labelText: 'Nama lahan (boleh dikosongkan)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selesai,
              style: gayaUtama(context),
              child: const Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }
}