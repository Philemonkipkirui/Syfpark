import 'package:flutter/material.dart';

class MallAd {
  final String id;
  final String imageAsset;
  final String title;
  final String description;
  final String url;

  const MallAd({
    required this.id,
    required this.imageAsset,
    required this.title,
    required this.description,
    required this.url,
  });
}

class MallBranding {
  final Color primary;
  final Color secondary;
  final Color textOnPrimary;
  final String logoAsset;
  final String heroImageAsset;

  const MallBranding({
    required this.primary,
    required this.secondary,
    required this.textOnPrimary,
    required this.logoAsset,
    required this.heroImageAsset,
  });
}

class Mall {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  /// meters for "nearby" decision
  final double proximityRadiusMeters;
  final MallBranding branding;
  final List<MallAd> ads;
  final String vehicleinfo_apiUrl;
  final String vehiclepayment_apiUrl;

  const Mall({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.proximityRadiusMeters,
    required this.branding,
    required this.ads,
    required this.vehicleinfo_apiUrl,
    required this.vehiclepayment_apiUrl, 
  });
}
