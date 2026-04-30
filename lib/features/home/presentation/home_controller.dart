import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/sqlite_service.dart';
import '../../../core/utils/location_utils.dart';

final nearbyBudayaProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final pos = await LocationUtils.getCurrentPosition();
  final allBudaya = await SqliteService.query('budaya');

  if (pos == null) return allBudaya.take(10).toList();

  final withDistance = allBudaya.where((b) {
    return b['lat'] != null && b['lng'] != null;
  }).map((b) {
    final distance = LocationUtils.haversineDistance(
      pos.latitude,
      pos.longitude,
      (b['lat'] as num).toDouble(),
      (b['lng'] as num).toDouble(),
    );
    return {...b, 'distance': distance};
  }).toList();

  withDistance.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

  return withDistance.take(10).toList();
});
