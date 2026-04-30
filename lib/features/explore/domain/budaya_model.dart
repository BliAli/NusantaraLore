class BudayaModel {
  final String id;
  final String nama;
  final String provinsi;
  final String kategori;
  final String deskripsi;
  final String isiLengkap;
  final String gambarUrl;
  final double? lat;
  final double? lng;
  final List<String> tags;
  final String? createdAt;

  const BudayaModel({
    required this.id,
    required this.nama,
    required this.provinsi,
    required this.kategori,
    this.deskripsi = '',
    this.isiLengkap = '',
    this.gambarUrl = '',
    this.lat,
    this.lng,
    this.tags = const [],
    this.createdAt,
  });

  factory BudayaModel.fromMap(Map<String, dynamic> map) {
    return BudayaModel(
      id: map['id'] ?? '',
      nama: map['nama'] ?? map['judul'] ?? '',
      provinsi: map['provinsi'] ?? map['asal'] ?? '',
      kategori: map['kategori'] ?? '',
      deskripsi: map['deskripsi'] ?? map['ringkasan'] ?? '',
      isiLengkap: map['isi_lengkap'] ?? map['isiLengkap'] ?? '',
      gambarUrl: map['gambar_url'] ?? map['gambar'] ?? '',
      lat: (map['lat'] as num?)?.toDouble() ??
          (map['koordinat'] != null
              ? (map['koordinat']['lat'] as num?)?.toDouble()
              : null),
      lng: (map['lng'] as num?)?.toDouble() ??
          (map['koordinat'] != null
              ? (map['koordinat']['lng'] as num?)?.toDouble()
              : null),
      tags: map['tags'] is List
          ? List<String>.from(map['tags'])
          : (map['tags'] is String ? (map['tags'] as String).split(',') : []),
      createdAt: map['created_at'] ?? map['createdAt'],
    );
  }

  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'nama': nama,
      'provinsi': provinsi,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'isi_lengkap': isiLengkap,
      'gambar_url': gambarUrl,
      'lat': lat,
      'lng': lng,
      'tags': tags.join(','),
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }
}
