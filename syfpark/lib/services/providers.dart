import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:syfpark/models/mall.dart';
import 'package:syfpark/services/location_service.dart';
import 'package:syfpark/services/mall_service.dart';

/// Static mall data
final mallsProvider = Provider<List<Mall>>((ref) => MallService.malls);

/// One-time location fetch (with permission handling)
final locationOnceProvider = FutureProvider<LocationResult>((ref) async {
  return await LocationService.instance.getCurrentPositionOnce();
});

/// Optional: user manual mall selection (via buttons)
/// null means "no manual override"
final selectedMallIdProvider = StateProvider<String?>((ref) => null);

/// Nearest mall based on current location (null if no location)
final nearestMallProvider = Provider<Mall?>((ref) {
  final locAsync = ref.watch(locationOnceProvider);
  return locAsync.maybeWhen(
    data: (result) {
      final pos = result.position;
      if (pos == null) return null;
      final nearest = MallService.nearestMallTo(GeoPoint(pos.latitude, pos.longitude));
      if (nearest == null) return null;

      // Only consider "in range" if within the mall's proximity radius.
      return nearest.distanceMeters <= nearest.mall.proximityRadiusMeters
          ? nearest.mall
          : null;
    },
    orElse: () => null,
  );
});

/// Effective mall = manual selection (if any) OR nearest (if in range)
final effectiveMallProvider = Provider<Mall?>((ref) {
  final manualId = ref.watch(selectedMallIdProvider);
  final malls = ref.watch(mallsProvider);

  if (manualId != null) {
    return malls.firstWhere(
      (m) => m.id == manualId,
      orElse: () => malls.first, // safe fallback but should match by id
    );
  }

  return ref.watch(nearestMallProvider);
});

/// Whether we should show the fallback homepage (no location or out of range)
final shouldShowHomepageProvider = Provider<bool>((ref) {
  // Show homepage if: no manual selection AND no in-range nearest mall.
  final manualId = ref.watch(selectedMallIdProvider);
  final nearest = ref.watch(nearestMallProvider);
  return manualId == null && nearest == null;
});
