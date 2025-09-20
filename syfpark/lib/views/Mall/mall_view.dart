import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syfpark/views/home/constants.dart';
import 'package:syfpark/services/providers.dart';
import 'package:syfpark/services/mall_service.dart';
import 'package:syfpark/models/mall.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syfpark/services/vehicle_services.dart';
import 'package:syfpark/views/Mall/dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class MallView extends ConsumerStatefulWidget {
  const MallView({super.key});

  @override
  ConsumerState<MallView> createState() => _MallViewState();
}

class _MallViewState extends ConsumerState<MallView> {
  final TextEditingController _controller = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    print('MallView initialized');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

Future<void> _launchNavigation(Mall mall) async {
  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  // Watch location provider for user's current position
  final locationAsync = ref.watch(locationOnceProvider);
  Position? userPosition;

  await locationAsync.when(
    data: (result) {
      if (result.position != null) {
        userPosition = result.position;
        print('User location: ${result.position?.latitude}, ${result.position?.longitude}');
      } else {
        print('Location fetch failed: ${result.error}');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unable to get your location: ${result.error ?? 'Unknown error'}')),
          );
        }
      }
    },
    loading: () {
      // Loading dialog already shown
    },
    error: (error, stack) {
      print('Location error: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location error: $error')),
        );
      }
    },
  );

  // Close loading dialog
  if (context.mounted) {
    Navigator.of(context).pop();
  }

  // Explicit null check with assertion
  if (!context.mounted || userPosition == null) {
    assert(userPosition != null, 'userPosition is null after location fetch');
    return;
  }

  // Use non-nullable Position
  final Position position = userPosition!;
  // Build Google Maps Directions URL
  final String origin = '${position.latitude},${position.longitude}';
  final String destination = '${mall.latitude},${mall.longitude}';
  final String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving';

  print('Launching Maps URL: $googleMapsUrl');

  try {
    final Uri uri = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening in browser...')),
        );
      }
    }
  } catch (e) {
    print('Failed to launch Maps: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open Maps: $e')),
      );
    }
  }
}
  @override
  Widget build(BuildContext context) {
    print('MallView build called');
    final mall = ref.watch(effectiveMallProvider);

    if (mall == null) {
      print('Redirecting to /home: mall is null');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedMallIdProvider.notifier).state = null;
        Navigator.pushReplacementNamed(context, '/home');
      });
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SizedBox.shrink(),
      );
    }

    print('mall.branding.textOnPrimary: ${mall.branding.textOnPrimary}');
    precacheImage(AssetImage(mall.branding.logoAsset), context);
    precacheImage(AssetImage(mall.branding.heroImageAsset), context);
    for (final ad in mall.ads) {
      precacheImage(AssetImage(ad.imageAsset), context);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(mall.branding.logoAsset, height: 32),
            const SizedBox(width: 8),
            Text(
              mall.name,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: mall.branding.textOnPrimary ?? AppColors.textOverlay,
                  ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                mall.branding.secondary ?? AppColors.textUnselected,
                (mall.branding.secondary ?? AppColors.textUnselected).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: mall.branding.textOnPrimary ?? AppColors.textOverlay),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(mall.branding.heroImageAsset),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: AppColors.border),
                  ),
                  width: double.infinity,
                  height: 200,
                ),
                Container(
                  color: Colors.black.withOpacity(0.3),
                  width: double.infinity,
                  height: 200,
                  alignment: Alignment.center,
                  child: Text(
                    'Welcome to ${mall.name}',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: AppColors.textOverlay,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(1.5, 1.5),
                              blurRadius: 3.0,
                            ),
                          ],
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(
                child: Card(
                  color: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.textSecondary),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: "Enter plate number",
                        hintStyle: TextStyle(color: AppColors.textUnselected),
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.textSecondary, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: Icon(
                          Icons.search,
                          color: mall.branding.secondary ?? AppColors.textUnselected,
                        ),
                      ),
                      style: TextStyle(color: AppColors.textPrimary),
                      onSubmitted: (plateNumber) async {
                        if (plateNumber.isEmpty) return;
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => Center(
                            child: CircularProgressIndicator(color: Colors.black),
                          ),
                        );
                        try {
                          final data = await VehicleService.fetchVehicleInfo(
                              plateNumber, mall.vehicleinfo_apiUrl);
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                          Dialogs.showVehicleDialog(
                            context,
                            plateNumber,
                            data,
                            mall.vehicleinfo_apiUrl,
                            mall.vehiclepayment_apiUrl,
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error fetching vehicle info: $e')),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.textSecondary, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 160,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: mall.ads.asMap().entries.map((entry) {
                          final ad = entry.value;
                          return Row(
                            children: [
                              ReusableAdCard(
                                imagePath: ad.imageAsset,
                                description: ad.description,
                                url: ad.url,
                              ),
                              const SizedBox(width: 12),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              mall.branding.secondary ?? AppColors.buttonSelected,
              (mall.branding.secondary ?? AppColors.buttonSelected).withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FooterButton(
              icon: Icons.home,
              label: 'Home',
              index: 0,
              selectedIndex: _selectedIndex,
              onTap: () {
                setState(() => _selectedIndex = 0);
                ref.read(selectedMallIdProvider.notifier).state = null;
                ref.read(hasRedirectedProvider.notifier).state = true;
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            FooterButton(
              icon: Icons.navigation,
              label: 'Navigation',
              index: 1,
              selectedIndex: _selectedIndex,
              onTap: () {
                setState(() => _selectedIndex = 1);
                print('Navigation clicked for ${mall.name}');
                _launchNavigation(mall);
              },
            ),
            FooterButton(
              icon: Icons.history,
              label: 'History',
              index: 2,
              selectedIndex: _selectedIndex,
              onTap: () {
                setState(() => _selectedIndex = 2);
                print('History clicked for ${mall.name}');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ... (FooterButton and ReusableAdCard unchanged, same as provided)
class FooterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;

  const FooterButton({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == selectedIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  AppColors.buttonSelected,
                  AppColors.buttonSelected.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : AppColors.buttonUnselected,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: isSelected ? AppColors.accent.withOpacity(0.3) : Colors.transparent,
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.textSecondary : AppColors.textUnselected,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: isSelected ? AppColors.textSecondary : AppColors.textUnselected,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReusableAdCard extends StatelessWidget {
  final String imagePath;
  final String description;
  final String url;

  const ReusableAdCard({
    super.key,
    required this.imagePath,
    required this.description,
    required this.url,
  });

  Future<void> _launchURL(BuildContext context) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _launchURL(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(1.0),
        child: Container(
          width: 200,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.textSecondary),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.textOverlay,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}