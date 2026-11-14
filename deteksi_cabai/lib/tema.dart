import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Warna merek (sama di kedua mode)
class Warna {
  static const prussian = Color(0xFF003151);
  static const emas = Color(0xFFFFD700);
}

// Palet yang berbeda per mode. Pakai lewat: context.palet.kartu
@immutable
class Palet extends ThemeExtension<Palet> {
  final Color latar;
  final Color kartu;
  final Color garis;
  final Color teks;
  final Color teksRedup;
  final Color aksen;
  final Color hijau;
  final Color merah;

  const Palet({
    required this.latar,
    required this.kartu,
    required this.garis,
    required this.teks,
    required this.teksRedup,
    required this.aksen,
    required this.hijau,
    required this.merah,
  });

  static const gelap = Palet(
    latar: Color(0xFF050B14),
    kartu: Color(0xFF0E1826),
    garis: Color(0xFF1C2B3D),
    teks: Color(0xFFE8EEF5),
    teksRedup: Color(0xFF8A9BB0),
    aksen: Color(0xFFFFD700),
    hijau: Color(0xFF10B981),
    merah: Color(0xFFEF4444),
  );

  static const terang = Palet(
    latar: Color(0xFFF2F5F9),
    kartu: Color(0xFFFFFFFF),
    garis: Color(0xFFDDE4ED),
    teks: Color(0xFF0F1B2A),
    teksRedup: Color(0xFF5A6A7E),
    aksen: Color(0xFF003151),
    hijau: Color(0xFF047857),
    merah: Color(0xFFDC2626),
  );

  @override
  Palet copyWith({
    Color? latar,
    Color? kartu,
    Color? garis,
    Color? teks,
    Color? teksRedup,
    Color? aksen,
    Color? hijau,
    Color? merah,
  }) {
    return Palet(
      latar: latar ?? this.latar,
      kartu: kartu ?? this.kartu,
      garis: garis ?? this.garis,
      teks: teks ?? this.teks,
      teksRedup: teksRedup ?? this.teksRedup,
      aksen: aksen ?? this.aksen,
      hijau: hijau ?? this.hijau,
      merah: merah ?? this.merah,
    );
  }

  @override
  Palet lerp(ThemeExtension<Palet>? other, double t) {
    if (other is! Palet) return this;
    return Palet(
      latar: Color.lerp(latar, other.latar, t)!,
      kartu: Color.lerp(kartu, other.kartu, t)!,
      garis: Color.lerp(garis, other.garis, t)!,
      teks: Color.lerp(teks, other.teks, t)!,
      teksRedup: Color.lerp(teksRedup, other.teksRedup, t)!,
      aksen: Color.lerp(aksen, other.aksen, t)!,
      hijau: Color.lerp(hijau, other.hijau, t)!,
      merah: Color.lerp(merah, other.merah, t)!,
    );
  }
}

extension PaletKonteks on BuildContext {
  Palet get palet => Theme.of(this).extension<Palet>()!;
}

ThemeData buatTema(Brightness b) {
  final p = b == Brightness.dark ? Palet.gelap : Palet.terang;
  final skema = ColorScheme.fromSeed(
    seedColor: Warna.prussian,
    brightness: b,
  ).copyWith(primary: p.aksen, surface: p.kartu);
  final dasar = ThemeData(brightness: b).textTheme;

  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: skema,
    scaffoldBackgroundColor: p.latar,
    textTheme: dasar.apply(bodyColor: p.teks, displayColor: p.teks),
    extensions: [p],
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: p.kartu),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.kartu,
      indicatorColor: p.aksen.withValues(alpha: 0.14),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: s.contains(WidgetState.selected) ? p.aksen : p.teksRedup,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? p.aksen : p.teksRedup,
        ),
      ),
    ),
  );
}

// Menyimpan pilihan mode tampilan di HP (tanpa internet)
class KontrolTema extends ValueNotifier<ThemeMode> {
  KontrolTema() : super(ThemeMode.system);

  static const _kunci = 'mode_tema';

  Future<void> muat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      switch (prefs.getString(_kunci)) {
        case 'terang':
          value = ThemeMode.light;
        case 'gelap':
          value = ThemeMode.dark;
        default:
          value = ThemeMode.system;
      }
    } catch (_) {
      value = ThemeMode.system;
    }
  }

  Future<void> atur(ThemeMode mode) async {
    value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      final teks = switch (mode) {
        ThemeMode.light => 'terang',
        ThemeMode.dark => 'gelap',
        ThemeMode.system => 'sistem',
      };
      await prefs.setString(_kunci, teks);
    } catch (_) {
      // Gagal menyimpan tidak mengganggu pemakaian.
    }
  }
}

final kontrolTema = KontrolTema();