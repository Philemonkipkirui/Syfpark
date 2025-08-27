// lib/views/mall_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syfpark/services/providers.dart';
import 'package:syfpark/models/mall.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syfpark/services/vehicle_services.dart';
import 'package:syfpark/services/dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class MallView extends ConsumerStatefulWidget {
  const MallView({super.key});

  @override
  ConsumerState<MallView> createState() => _MallViewState();
}

class _MallViewState extends ConsumerState<MallView> {
  final TextEditingController _controller = TextEditingController();
  int _selectedIndex = 0; // Tracks selected footer button

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mall = ref.watch(effectiveMallProvider);

    if (mall == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/homepage');
      });
      return const Scaffold(
        body: Center(child: Text('No mall selected')),
      );
    }

    // Precache assets
    precacheImage(AssetImage(mall.branding.logoAsset), context);
    precacheImage(AssetImage(mall.branding.heroImageAsset), context);
    for (final ad in mall.ads) {
      precacheImage(AssetImage(ad.imageAsset), context);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(mall.branding.logoAsset, height: 32),
            const SizedBox(width: 8),
            Text(
              mall.name,
              style: TextStyle(
                color: mall.branding.textOnPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: mall.branding.secondary,
        iconTheme: IconThemeData(color: mall.branding.textOnPrimary),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero image with overlay text
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  mall.branding.heroImageAsset,
                  fit: BoxFit.cover,
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: "Enter plate number",
                      border: InputBorder.none,
                      suffixIcon: Icon(Icons.search, color: mall.branding.secondary),
                    ),
                    style: TextStyle(color: mall.branding.textOnPrimary),
                    onSubmitted: (plateNumber) async {
                      if (plateNumber.isEmpty) return;
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );
                      final data = await VehicleService.fetchVehicleInfo(plateNumber, mall.vehicleinfo_apiUrl);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      Dialogs.showVehicleDialog(context, plateNumber, data);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Horizontal scrolling ad container
            const Divider(color: Colors.grey, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
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
        color: mall.branding.secondary,
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
                Navigator.pushReplacementNamed(context, '/homepage');
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
    final Color activeColor = Colors.grey[800]!;
    final Color inactiveColor = Colors.grey[500]!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[300] : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? activeColor : inactiveColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 12,
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
      onTap: () => _launchURL(context), // Pass context to _launchURL
      child: Container(
        width: 200,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image without rotation
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
                ),
              ),
            ),
            // Overlay Text
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
    );
  }
}