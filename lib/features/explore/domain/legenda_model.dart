class LegendaModel {
  final String id;
  final String judul;
  final String asal;
  final String provinsi;
  final double? lat;
  final double? lng;
  final String kategori;
  final List<String> tokoh;
  final String ringkasan;
  final String isiLengkap;
  final String gambar;
  final List<String> tags;

  const LegendaModel({
    required this.id,
    required this.judul,
    required this.asal,
    required this.provinsi,
    this.lat,
    this.lng,
    required this.kategori,
    this.tokoh = const [],
    this.ringkasan = '',
    this.isiLengkap = '',
    this.gambar = '',
    this.tags = const [],
  });

  factory LegendaModel.fromJson(Map<String, dynamic> json) {
    final koordinat = json['koordinat'] as Map<String, dynamic>?;
    return LegendaModel(
      id: json['id'] ?? '',
      judul: json['judul'] ?? '',
      asal: json['asal'] ?? '',
      provinsi: json['provinsi'] ?? '',
      lat: (koordinat?['lat'] as num?)?.toDouble(),
      lng: (koordinat?['lng'] as num?)?.toDouble(),
      kategori: json['kategori'] ?? '',
      tokoh: List<String>.from(json['tokoh'] ?? []),
      ringkasan: json['ringkasan'] ?? '',
      isiLengkap: json['isi_lengkap'] ?? '',
      gambar: json['gambar'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'asal': asal,
      'provinsi': provinsi,
      'koordinat': lat != null && lng != null ? {'lat': lat, 'lng': lng} : null,
      'kategori': kategori,
      'tokoh': tokoh,
      'ringkasan': ringkasan,
      'isi_lengkap': isiLengkap,
      'gambar': gambar,
      'tags': tags,
    };
  }
}
