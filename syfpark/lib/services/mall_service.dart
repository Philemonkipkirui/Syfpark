import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:syfpark/models/mall.dart';

@immutable
class GeoPoint {
  final double lat;
  final double lng;
  const GeoPoint(this.lat, this.lng);
}

class MallService {
  // Mock malls with distinct branding + ads.
  static final List<Mall> malls = [
    Mall(
      id: 'ridgeways',
      name: 'RidgeWays Mall',
      latitude: -1.225032,   // mock coords
      longitude: 36.839835,  // mock coords
      vehicleinfo_apiUrl:'http://ridgemall.syfe.co.ke/apidetails/',
      vehiclepayment_apiUrl:'http://ridgemall.syfe.co.ke/apipushpayment//',
      proximityRadiusMeters: 600,
      branding: MallBranding(
        primary: const Color(0xFFEEEEEE),
        secondary: const Color(0xFFE0E0E0),
        textOnPrimary:  Colors.white,
        logoAsset: 'assets/logos/geeko.png',
        heroImageAsset: 'assets/images/hero/ridgeways_hero.jpg',
      ),
      ads: const [
        MallAd(
          id: 'rw-1',
          imageAsset: 'assets/images/ads/ridgeways_1.jpg',
          title: 'Weekend Parking Deal',
          description: 'Park 3hrs, pay for 2',
          url: 'https://ridgeways.example/promo',
        ),
        MallAd(
          id: 'rw-2',
          imageAsset: 'assets/images/ads/ridgeways_2.jpg',
          title: 'Food Court Bonanza',
          description: 'Up to 40% off burgers',
          url: 'https://ridgeways.example/food',
        ),
        MallAd(
          id: 'rw-3',
          imageAsset: 'assets/images/ads/ridgeways_3.jpg',
          title: 'Cinema Night',
          description: 'Late shows, free popcorn',
          url: 'https://ridgeways.example/cinema',
        ),
      ],
    ),
    Mall(
      id: 'rng',
      name: 'RNG Mall',
      latitude: -1.285506,   // mock coords
      longitude: 36.828712,  // mock coords
      proximityRadiusMeters: 700,
      vehicleinfo_apiUrl:'http://ridgemall.syfe.co.ke/apidetails/',
      vehiclepayment_apiUrl:'http://ridgemall.syfe.co.ke/apipushpayment/',
      branding: MallBranding(
        primary: const Color(0xFF0D47A1),
        secondary: const Color(0xFF90CAF9),
        textOnPrimary: Colors.white,
        logoAsset: 'assets/images/logos/rng_logo.png',
        heroImageAsset: 'assets/images/hero/rng_hero.jpg',
      ),
      ads: const [
        MallAd(
          id: 'rng-1',
          imageAsset: 'assets/images/ads/rng_1.jpg',
          title: 'EV Charging Promo',
          description: 'First hour free',
          url: 'https://rng.example/ev',
        ),
        MallAd(
          id: 'rng-2',
          imageAsset: 'assets/images/ads/rng_2.jpg',
          title: 'Fashion Week',
          description: 'New arrivals 30% off',
          url: 'https://rng.example/fashion',
        ),
      ],
    ),
    Mall(
      id: 'mall3',
      name: 'Mall 3',
      latitude: -1.3000,   // mock coords
      longitude: 36.8500,  // mock coords
      proximityRadiusMeters: 800,
      vehicleinfo_apiUrl:'http://ridgemall.syfe.co.ke/apidetails/',
      vehiclepayment_apiUrl:'http://ridgemall.syfe.co.ke/apipushpayment/',
      branding: MallBranding(
        primary: const Color(0xFF4E342E),
        secondary: const Color(0xFFD7CCC8),
        textOnPrimary: Colors.white,
        logoAsset: 'assets/images/logos/mall3_logo.png',
        heroImageAsset: 'assets/images/hero/mall3_hero.jpg',
      ),
      ads: const [
        MallAd(
          id: 'm3-1',
          imageAsset: 'assets/images/ads/m3_1.jpg',
          title: 'Grocery Savings',
          description: 'Daily essentials 20% off',
          url: 'https://mall3.example/grocery',
        ),
      ],
    ),
  ];

  /// Returns nearest mall and distance (m). Null if list empty.
  static ({Mall mall, double distanceMeters})? nearestMallTo(GeoPoint user) {
    if (malls.isEmpty) return null;
    Mall best = malls.first;
    double bestDist = _haversineMeters(
      user.lat, user.lng, best.latitude, best.longitude,
    );
    for (int i = 1; i < malls.length; i++) {
      final m = malls[i];
      final d = _haversineMeters(user.lat, user.lng, m.latitude, m.longitude);
      if (d < bestDist) {
        best = m;
        bestDist = d;
      }
    }
    return (mall: best, distanceMeters: bestDist);
  }

  /// Haversine distance in meters.
  static double _haversineMeters(
    double lat1, double lon1, double lat2, double lon2,
  ) {
    const earthRadius = 6371000.0; // meters
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = math.sin(dLat/2) * math.sin(dLat/2) +
        math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) *
        math.sin(dLon/2) * math.sin(dLon/2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a));
    return earthRadius * c;
  }

  static double _deg2rad(double deg) => deg * math.pi / 180.0;
}
