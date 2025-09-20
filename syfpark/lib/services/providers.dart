// lib/services/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:syfpark/models/mall.dart';
import 'package:syfpark/services/location_service.dart';
import 'package:syfpark/services/mall_service.dart';

final mallsProvider = Provider<List<Mall>>((ref) => MallService.malls);

final locationOnceProvider = FutureProvider<LocationResult>((ref) async {
  return await LocationService.instance.getCurrentPositionOnce();
});

final selectedMallIdProvider = StateProvider<String?>((ref) => null);

final nearestMallProvider = Provider<Mall?>((ref) {
  final locAsync = ref.watch(locationOnceProvider);
  return locAsync.maybeWhen(
    data: (result) {
      final pos = result.position;
      if (pos == null) return null;
      final nearest = MallService.nearestMallTo(GeoPoint(pos.latitude, pos.longitude));
      if (nearest == null) return null;
      return nearest.distanceMeters <= nearest.mall.proximityRadiusMeters
          ? nearest.mall
          : null;
    },
    orElse: () => null,
  );
});

final effectiveMallProvider = Provider<Mall?>((ref) {
  final manualId = ref.watch(selectedMallIdProvider);
  final malls = ref.watch(mallsProvider);
  if (manualId != null) {
    return malls.firstWhere(
      (m) => m.id == manualId,
      orElse: () => malls.first,
    );
  }
  return ref.watch(nearestMallProvider);
});

final shouldShowHomepageProvider = Provider<bool>((ref) {
  final manualId = ref.watch(selectedMallIdProvider);
  final nearest = ref.watch(nearestMallProvider);
  return manualId == null && nearest == null;
});

final hasRedirectedProvider = StateProvider<bool>((ref) => false);