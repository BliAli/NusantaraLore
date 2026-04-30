import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/location_utils.dart';

class BudayaMapScreen extends StatefulWidget {
  const BudayaMapScreen({super.key});

  @override
  State<BudayaMapScreen> createState() => _BudayaMapScreenState();
}

class _BudayaMapScreenState extends State<BudayaMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _gyroEnabled = false;
  StreamSubscription? _gyroSub;
  double _tiltX = 0;
  double _tiltY = 0;

  static const _initialCamera = CameraPosition(
    target: LatLng(-2.5, 118.0),
    zoom: 5,
  );

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  @override
  void dispose() {
    _gyroSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _goToUserLocation(animate: false);
  }

  Future<void> _goToUserLocation({bool animate = true}) async {
    final pos = await LocationUtils.getCurrentPosition();
    if (pos == null || !mounted || _mapController == null) return;

    final cam = CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 14),
    );

    if (animate) {
      _mapController!.animateCamera(cam);
    } else {
      _mapController!.moveCamera(cam);
    }
  }

  void _toggleGyro() {
    setState(() => _gyroEnabled = !_gyroEnabled);
    if (_gyroEnabled) {
      _gyroSub = gyroscopeEventStream().listen((event) {
        setState(() {
          _tiltX = event.y * 0.5;
          _tiltY = event.x * 0.5;
        });

        if (_mapController != null &&
            (_tiltX.abs() > 0.3 || _tiltY.abs() > 0.3)) {
          _mapController!.moveCamera(
            CameraUpdate.scrollBy(_tiltX * 3, _tiltY * 3),
          );
        }
      });
    } else {
      _gyroSub?.cancel();
      _gyroSub = null;
      setState(() {
        _tiltX = 0;
        _tiltY = 0;
      });
    }
  }

  Future<void> _loadMarkers() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/legenda.json');
      final data = json.decode(jsonString);
      final legenda = data['legenda'] as List<dynamic>? ?? [];

      final markers = <Marker>{};
      for (final item in legenda) {
        final koordinat = item['koordinat'];
        if (koordinat != null) {
          final lat = (koordinat['lat'] as num?)?.toDouble();
          final lng = (koordinat['lng'] as num?)?.toDouble();
          if (lat != null && lng != null) {
            final id = item['id'] ?? '${lat}_$lng';
            markers.add(
              Marker(
                markerId: MarkerId(id.toString()),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(
                  title: item['judul'] ?? item['nama'] ?? '',
                  snippet: item['asal'] ?? item['provinsi'] ?? '',
                  onTap: () => _showBudayaInfo(item),
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
              ),
            );
          }
        }
      }

      if (mounted) {
        setState(() {
          _markers.addAll(markers);
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
      appBar: AppBar(
        title: const Text('Peta Budaya'),
        actions: [
          IconButton(
            onPressed: _toggleGyro,
            icon: Icon(
              _gyroEnabled ? Icons.screen_rotation : Icons.screen_lock_rotation,
            ),
            tooltip: _gyroEnabled
                ? 'Matikan kontrol gyroscope'
                : 'Miringkan HP untuk geser peta',
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: _initialCamera,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
          if (_gyroEnabled)
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: kColorAccent.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.screen_rotation,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Gyroscope aktif — miringkan HP untuk geser peta '
                        '(X: ${_tiltX.toStringAsFixed(1)}, Y: ${_tiltY.toStringAsFixed(1)})',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToUserLocation,
        backgroundColor: kColorPrimary,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
