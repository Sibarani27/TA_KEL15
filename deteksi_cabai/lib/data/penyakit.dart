class Penyakit {
  final String nama;
  final String ciri;
  final String saran;
  final bool sehat;
  const Penyakit(this.nama, this.ciri, this.saran, {this.sehat = false});
}

const kamusPenyakit = <String, Penyakit>{
  'daun_sehat': Penyakit(
    'Daun sehat',
    'Warna hijau merata, permukaan rata, tanpa bercak atau gulungan.',
    'Lanjutkan perawatan rutin dan periksa tanaman secara berkala.',
    sehat: true,
  ),
  'trips': Penyakit(
    'Serangan trips',
    'Daun tampak keperakan atau kecokelatan, tepi menggulung ke atas, pucuk mengerut.',
    'Periksa sisi bawah daun dan pucuk. Konsultasikan cara pengendalian ke penyuluh pertanian.',
  ),
  'layu_fusarium': Penyakit(
    'Layu Fusarium',
    'Tanaman layu, daun menguning mulai dari bagian bawah, pangkal batang bisa kecokelatan.',
    'Pisahkan tanaman yang terserang, hindari genangan air, dan konsultasikan ke penyuluh.',
  ),
  'antraknosa': Penyakit(
    'Antraknosa',
    'Bercak cekung cokelat sampai kehitaman, paling sering terlihat pada buah.',
    'Buang bagian yang terserang, jaga kebersihan lahan, dan kurangi kelembapan berlebih.',
  ),
  'virus_keriting': Penyakit(
    'Virus keriting',
    'Daun menggulung, mengerut, bergelombang, atau mengecil.',
    'Pisahkan tanaman yang terserang berat dan konsultasikan pengendalian ke penyuluh.',
  ),
  'virus_kuning': Penyakit(
    'Virus kuning',
    'Daun menguning atau pucat, sering berpola belang.',
    'Pisahkan tanaman yang terserang berat dan konsultasikan pengendalian ke penyuluh.',
  ),
};

String kunciKelas(String s) =>
    s.trim().toLowerCase().replaceAll(RegExp(r'[\s\-]+'), '_');