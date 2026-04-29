import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/network/connectivity_service.dart';

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return ConnectivityService.onConnectivityChanged;
});

final isOnlineProvider = FutureProvider<bool>((ref) {
  return ConnectivityService.isConnected();
});
