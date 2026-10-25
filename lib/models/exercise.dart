/// Model data satu gerakan peregangan.
///
/// Bentuk field sengaja dibuat datar (flat) agar pemetaan dari JSON lokal
/// maupun respons REST API nanti tidak perlu logika tambahan.
class Exercise {
  const Exercise({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.deskripsi,
    required this.gambar,
    required this.durasiDetik,
    required this.repetisi,
    required this.tingkat,
    required this.posisi,
    required this.target,
    required this.tujuan,
    required this.langkah,
    required this.kesalahanUmum,
    required this.manfaat,
    this.peringatan,
    this.populer = false,
  });

  final String id;

  /// Nama gerakan, contoh: "Putar Leher Perlahan".
  final String nama;

  /// Slug kategori, contoh: "leher-bahu".
  final String kategori;

  final String deskripsi;

  /// Path aset lokal atau URL gambar dari API.
  final String gambar;

  final int durasiDetik;
  final String repetisi;

  /// Ringan | Sedang.
  final String tingkat;

  /// Duduk | Berdiri | Merangkak.
  final String posisi;

  final List<String> target;
  final String tujuan;
  final List<String> langkah;
  final List<String> kesalahanUmum;

  /// Null bila gerakan aman untuk umum.
  final String? peringatan;

  final List<String> manfaat;

  /// Penanda untuk bagian "Populer" di beranda.
  /// Bisa diganti metrik lain (jumlah dilihat) saat memakai API.
  final bool populer;

  /// Membaca satu objek JSON. Nilai yang hilang diisi default yang aman
  /// supaya UI tidak crash saat kontrak API berubah.
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: _asString(json['id']),
      nama: _asString(json['nama']),
      kategori: _asString(json['kategori']),
      deskripsi: _asString(json['deskripsi']),
      gambar: _asString(json['gambar']),
      durasiDetik: _asInt(json['durasiDetik']),
      repetisi: _asString(json['repetisi']),
      tingkat: _asString(json['tingkat'], fallback: 'Ringan'),
      posisi: _asString(json['posisi'], fallback: 'Duduk'),
      target: _asStringList(json['target']),
      tujuan: _asString(json['tujuan']),
      langkah: _asStringList(json['langkah']),
      kesalahanUmum: _asStringList(json['kesalahanUmum']),
      peringatan: _asNullableString(json['peringatan']),
      manfaat: _asStringList(json['manfaat']),
      populer: _asBool(json['populer']),
    );
  }

  /// Dipakai bila nanti data perlu dikirim balik ke API (mis. favorit).
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'nama': nama,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'gambar': gambar,
      'durasiDetik': durasiDetik,
      'repetisi': repetisi,
      'tingkat': tingkat,
      'posisi': posisi,
      'target': target,
      'tujuan': tujuan,
      'langkah': langkah,
      'kesalahanUmum': kesalahanUmum,
      'peringatan': peringatan,
      'manfaat': manfaat,
      'populer': populer,
    };
  }

  /// Contoh keluaran: "1 mnt" atau "1 mnt 30 dtk".
  String get durasiLabel {
    if (durasiDetik < 60) return '$durasiDetik dtk';
    final menit = durasiDetik ~/ 60;
    final sisa = durasiDetik % 60;
    return sisa == 0 ? '$menit mnt' : '$menit mnt $sisa dtk';
  }

  bool get memilikiPeringatan =>
      peringatan != null && peringatan!.trim().isNotEmpty;

  /// Salin objek dengan sebagian field diganti (mis. status favorit).
  Exercise copyWith({
    String? nama,
    String? kategori,
    String? deskripsi,
    String? gambar,
    int? durasiDetik,
    String? repetisi,
    String? tingkat,
    String? posisi,
    List<String>? target,
    String? tujuan,
    List<String>? langkah,
    List<String>? kesalahanUmum,
    String? peringatan,
    List<String>? manfaat,
    bool? populer,
  }) {
    return Exercise(
      id: id,
      nama: nama ?? this.nama,
      kategori: kategori ?? this.kategori,
      deskripsi: deskripsi ?? this.deskripsi,
      gambar: gambar ?? this.gambar,
      durasiDetik: durasiDetik ?? this.durasiDetik,
      repetisi: repetisi ?? this.repetisi,
      tingkat: tingkat ?? this.tingkat,
      posisi: posisi ?? this.posisi,
      target: target ?? this.target,
      tujuan: tujuan ?? this.tujuan,
      langkah: langkah ?? this.langkah,
      kesalahanUmum: kesalahanUmum ?? this.kesalahanUmum,
      peringatan: peringatan ?? this.peringatan,
      manfaat: manfaat ?? this.manfaat,
      populer: populer ?? this.populer,
    );
  }

  // ---------------------------------------------------------------------------
  // Helper parsing: JSON dari API bisa saja mengirim tipe yang tidak konsisten.
  // ---------------------------------------------------------------------------

  static String _asString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static String? _asNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase();
    return text == 'true' || text == '1' || text == 'ya';
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    if (value is String && value.trim().isNotEmpty) {
      return <String>[value.trim()];
    }
    return const <String>[];
  }
}
