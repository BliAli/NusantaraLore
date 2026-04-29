import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/location_utils.dart';

class BudayaMapScreen extends StatefulWidget {
  const BudayaMapScreen({super.key});

  @override
  State<BudayaMapScreen> createState() => _BudayaMapScreenState();
}

class _BudayaMapScreenState extends State<BudayaMapScreen> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  LatLng _center = const LatLng(-2.5, 118.0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    final pos = await LocationUtils.getCurrentPosition();
    if (pos != null && mounted) {
      setState(() => _center = LatLng(pos.latitude, pos.longitude));
    }
  }

  Future<void> _loadMarkers() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/legenda.json');
      final data = json.decode(jsonString);
      final legenda = data['legenda'] as List<dynamic>? ?? [];

      final markers = <Marker>[];
      for (final item in legenda) {
        final koordinat = item['koordinat'];
        if (koordinat != null) {
          final lat = (koordinat['lat'] as num?)?.toDouble();
          final lng = (koordinat['lng'] as num?)?.toDouble();
          if (lat != null && lng != null) {
            markers.add(
              Marker(
                point: LatLng(lat, lng),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () => _showBudayaInfo(item),
                  child: const Icon(
                    Icons.location_on,
                    color: kColorPrimary,
                    size: 40,
                  ),
                ),
              ),
            );
          }
        }
      }

      if (mounted) {
        setState(() {
          _markers = markers;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showBudayaInfo(dynamic item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['judul'] ?? item['nama'] ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item['asal'] ?? item['provinsi'] ?? '',
              style: const TextStyle(color: kColorTextLight),
            ),
            const SizedBox(height: 8),
            Text(
              item['ringkasan'] ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Peta Budaya')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 5,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.nusantaralore.app',
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final pos = await LocationUtils.getCurrentPosition();
          if (pos != null) {
            _mapController.move(
              LatLng(pos.latitude, pos.longitude),
              12,
            );
          }
        },
        backgroundColor: kColorPrimary,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
