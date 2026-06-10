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
          _tiltX = event.y * 2.0;
          _tiltY = event.x * 2.0;
        });

        if (_mapController != null &&
            (_tiltX.abs() > 0.1 || _tiltY.abs() > 0.1)) {
          _mapController!.moveCamera(
            CameraUpdate.scrollBy(_tiltX * 8, _tiltY * 8),
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
    final gambar = item['gambar'] as String? ?? '';
    final judul = item['judul'] ?? item['nama'] ?? '';
    final asal = item['asal'] ?? item['provinsi'] ?? '';
    final kategori = item['kategori'] as String? ?? '';
    final ringkasan = item['ringkasan'] as String? ?? '';
    final isiLengkap = item['isi_lengkap'] as String? ?? '';
    final tokohList = item['tokoh'] as List<dynamic>? ?? [];
    final tagsList = item['tags'] as List<dynamic>? ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: kColorBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // ── Handle bar ──
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Hero Image ──
              if (gambar.isNotEmpty)
                Container(
                  height: 200,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          gambar,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: kColorPrimary.withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.auto_stories,
                              size: 64,
                              color: kColorPrimary,
                            ),
                          ),
                        ),
                        // Gradient overlay di bawah
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.6),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Kategori badge di gambar
                        if (kategori.isNotEmpty)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: kColorAccent.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                kategori[0].toUpperCase() +
                                    kategori.substring(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              // ── Title & Origin ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  judul,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kColorText,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: kColorTextLight),
                    const SizedBox(width: 4),
                    Text(
                      asal,
                      style: const TextStyle(
                        color: kColorTextLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Tokoh ──
              if (tokohList.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Tokoh',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: kColorText,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: tokohList
                        .map((t) => Chip(
                              avatar: const CircleAvatar(
                                backgroundColor: kColorPrimary,
                                child: Icon(Icons.person,
                                    size: 14, color: Colors.white),
                              ),
                              label: Text(t.toString(),
                                  style: const TextStyle(fontSize: 12)),
                              backgroundColor:
                                  kColorPrimary.withValues(alpha: 0.08),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ),
              ],

              // ── Divider ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Divider(height: 1),
              ),

              // ── Ringkasan ──
              if (ringkasan.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    ringkasan,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: kColorTextLight,
                      height: 1.5,
                    ),
                  ),
                ),

              // ── Isi Lengkap ──
              if (isiLengkap.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Text(
                    isiLengkap,
                    style: const TextStyle(
                      fontSize: 14,
                      color: kColorText,
                      height: 1.6,
                    ),
                  ),
                ),

              // ── Tags ──
              if (tagsList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: tagsList
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: kColorSecondary.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '#${tag.toString()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: kColorText,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
            ],
          ),
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
                      Flexible(
                        child: Text(
                          'Gyroscope aktif — miringkan HP untuk geser peta '
                          '(X: ${_tiltX.toStringAsFixed(1)}, Y: ${_tiltY.toStringAsFixed(1)})',
                          style:
                              const TextStyle(color: Colors.white, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
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
