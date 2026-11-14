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

  void _pindah(int i) => setState(() => _tab = i);

  @override
  Widget build(BuildContext context) {
    final halaman = <Widget>[
      HalamanHome(pindahTab: _pindah),
      const HalamanCamera(),
      const HalamanObat(),
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