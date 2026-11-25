import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Warna {
  static const ungu = Color(0xFF6B46D9);
  static const unguTua = Color(0xFF4B2FB0);
  static const unguGelap = Color(0xFF1E1635);
  static const unguMuda = Color(0xFFE4DAFF);

  // Nama lama dipertahankan supaya file lain tidak perlu diubah.
  static const prussian = ungu;
  static const emas = unguMuda;
}

@immutable
class Palet extends ThemeExtension<Palet> {
  final Color latar;
  final Color kartu;
  final Color garis;
  final Color teks;
  final Color teksRedup;
  final Color aksen;
  final Color aksenMuda;
  final Color hijau;
  final Color merah;

  const Palet({
    required this.latar,
    required this.kartu,
    required this.garis,
    required this.teks,
    required this.teksRedup,
    required this.aksen,
    required this.aksenMuda,
    required this.hijau,
    required this.merah,
  });

  static const gelap = Palet(
    latar: Color(0xFF120D24),
    kartu: Color(0xFF1D1638),
    garis: Color(0xFF2E2552),
    teks: Color(0xFFF1EBFF),
    teksRedup: Color(0xFFA89FC8),
    aksen: Color(0xFFB7A1FF),
    aksenMuda: Color(0xFF2A2150),
    hijau: Color(0xFF34D399),
    merah: Color(0xFFF87171),
  );

  static const terang = Palet(
    latar: Color(0xFFF7F3FF),
    kartu: Color(0xFFFFFFFF),
    garis: Color(0xFFE7DFFA),
    teks: Color(0xFF231B3D),
    teksRedup: Color(0xFF5F5780),
    aksen: Color(0xFF6B46D9),
    aksenMuda: Color(0xFFEFE8FF),
    hijau: Color(0xFF15803D),
    merah: Color(0xFFB42318),
  );

  @override
  Palet copyWith({
    Color? latar,
    Color? kartu,
    Color? garis,
    Color? teks,
    Color? teksRedup,
    Color? aksen,
    Color? aksenMuda,
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
      aksenMuda: aksenMuda ?? this.aksenMuda,
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
      aksenMuda: Color.lerp(aksenMuda, other.aksenMuda, t)!,
      hijau: Color.lerp(hijau, other.hijau, t)!,
      merah: Color.lerp(merah, other.merah, t)!,
    );
  }
}

extension PaletKonteks on BuildContext {
  Palet get palet => Theme.of(this).extension<Palet>()!;
}

// Gradasi ungu untuk header Home dan Camera
LinearGradient gradienUngu(BuildContext c) {
  final gelap = Theme.of(c).brightness == Brightness.dark;
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: gelap
        ? const [Color(0xFF4B2FB0), Color(0xFF2A1D5E)]
        : const [Color(0xFF7C5CE6), Color(0xFF5B3BC4)],
  );
}

ThemeData buatTema(Brightness b) {
  final gelap = b == Brightness.dark;
  final p = gelap ? Palet.gelap : Palet.terang;
  final skema = ColorScheme.fromSeed(
    seedColor: Warna.ungu,
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
      indicatorColor: p.aksen.withValues(alpha: 0.16),
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
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.aksen : p.aksenMuda,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? (gelap ? Colors.black : Colors.white)
              : p.teksRedup,
        ),
        side: const WidgetStatePropertyAll(BorderSide.none),
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