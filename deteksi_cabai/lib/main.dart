import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tema.dart';
import 'halaman/cangkang.dart';
import 'data/riwayat.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await kontrolTema.muat();
  await riwayat.muat();
  runApp(const AplikasiCabai());
}

class AplikasiCabai extends StatelessWidget {
  const AplikasiCabai({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: kontrolTema,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Cek Cabai',
          debugShowCheckedModeBanner: false,
          theme: buatTema(Brightness.light),
          darkTheme: buatTema(Brightness.dark),
          themeMode: mode,
          builder: (context, child) {
            final gelap = Theme.of(context).brightness == Brightness.dark;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: (gelap
                      ? SystemUiOverlayStyle.light
                      : SystemUiOverlayStyle.dark)
                  .copyWith(statusBarColor: Colors.transparent),
              child: child!,
            );
          },
          home: const Cangkang(),
        );
      },
    );
  }
}