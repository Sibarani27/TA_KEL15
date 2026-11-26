import 'package:flutter/material.dart';
import 'camera.dart';
import 'home.dart';
import 'obat.dart';
import 'riwayat.dart';

class Cangkang extends StatefulWidget {
  const Cangkang({super.key});

  @override
  State<Cangkang> createState() => _CangkangState();
}

class _CangkangState extends State<Cangkang> {
  int _tab = 0;
  String? _filterObat; // kunci penyakit yang dibawa dari Home, null = semua

  // Pindah tab biasa: filter obat dikosongkan
  void _pindah(int i) => setState(() {
        _tab = i;
        _filterObat = null;
      });

  // Dari kartu penyakit di Home: buka tab Obat dengan filter penyakit itu
  void _bukaObat(String kunci) => setState(() {
        _tab = 2;
        _filterObat = kunci;
      });

  @override
  Widget build(BuildContext context) {
    final halaman = <Widget>[
      HalamanHome(pindahTab: _pindah, bukaObat: _bukaObat),
      const HalamanCamera(),
      HalamanObat(key: ValueKey(_filterObat), filterAwal: _filterObat),
      const HalamanRiwayat(),
    ];

    return Scaffold(
      // Hanya tab aktif yang dibangun, jadi kamera dan model
      // berhenti saat pindah tab.
      body: halaman[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _pindah,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_camera_outlined),
            selectedIcon: Icon(Icons.photo_camera),
            label: 'Camera',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'Obat',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}