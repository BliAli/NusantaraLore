import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/budaya_model.dart';
import '../domain/legenda_model.dart';
import '../../../core/database/sqlite_service.dart';

class BudayaRepository {
  Future<List<LegendaModel>> loadLegendaFromJson() async {
    final jsonString = await rootBundle.loadString('assets/data/legenda.json');
    final data = json.decode(jsonString);
    final list = data['legenda'] as List<dynamic>? ?? [];
    return list.map((e) => LegendaModel.fromJson(e)).toList();
  }

  Future<List<BudayaModel>> getAllBudaya() async {
    final rows = await SqliteService.query('budaya', orderBy: 'nama ASC');
    return rows.map((r) => BudayaModel.fromMap(r)).toList();
  }

  Future<BudayaModel?> getBudayaById(String id) async {
    final rows =
        await SqliteService.query('budaya', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return BudayaModel.fromMap(rows.first);
  }

  Future<List<BudayaModel>> searchBudaya(String query) async {
    final rows = await SqliteService.search(query);
    return rows.map((r) => BudayaModel.fromMap(r)).toList();
  }

  Future<List<BudayaModel>> getBudayaByKategori(String kategori) async {
    final rows = await SqliteService.query(
      'budaya',
      where: 'kategori = ?',
      whereArgs: [kategori],
    );
    return rows.map((r) => BudayaModel.fromMap(r)).toList();
  }

  Future<void> populateFromJson() async {
    final existing = await SqliteService.query('budaya', limit: 1);
    if (existing.isNotEmpty) return;

    final legendas = await loadLegendaFromJson();
    for (final legenda in legendas) {
      final budaya = BudayaModel(
        id: legenda.id,
        nama: legenda.judul,
        provinsi: legenda.provinsi,
        kategori: legenda.kategori,
        deskripsi: legenda.ringkasan,
        isiLengkap: legenda.isiLengkap,
        gambarUrl: legenda.gambar,
        lat: legenda.lat,
        lng: legenda.lng,
        tags: legenda.tags,
      );
      await SqliteService.insert('budaya', budaya.toSqliteMap());
    }
  }
}
