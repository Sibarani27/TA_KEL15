import 'package:flutter/material.dart';
import '../tema.dart';
import 'cangkang.dart';

class Sambutan extends StatelessWidget {
  const Sambutan({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final gelap = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: p.aksenMuda,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Warna.ungu.withValues(alpha: 0.18),
                          blurRadius: 36,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logow.jpeg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const Text(
                'Deteksi penyakit cabai langsung dari HP',
                style: TextStyle(
                  fontSize: 32,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.9,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Foto daun atau buah, lihat nama penyakitnya dan saran awalnya. '
                'Semua berjalan tanpa internet.',
                style: TextStyle(color: p.teksRedup, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 28),
              Material(
                color: p.aksen,
                borderRadius: BorderRadius.circular(32),
                child: InkWell(
                  borderRadius: BorderRadius.circular(32),
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const Cangkang()),
                  ),
                  child: Container(
                    height: 64,
                    padding: const EdgeInsets.fromLTRB(28, 0, 8, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Mulai',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: gelap ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: gelap ? Colors.black : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_forward, color: p.aksen),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}