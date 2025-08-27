import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

import 'package:syfpark/services/providers.dart';
import 'package:syfpark/views/mall_view.dart';
import 'package:syfpark/views/landing/landing_page.dart'; // Import LandingPage

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  final Color backgroundColor = const Color(0xFFF5F5F5);

  // Sign-out function
  Future<void> _signOut(BuildContext context) async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      // Sign out from Google (if signed in with Google)
      await GoogleSignIn().signOut();
      // Navigate to LandingPage
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LandingPage()),
        );
      }
    } catch (e) {
      // Show error dialog if sign-out fails
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Sign Out Error'),
            content: Text('Failed to sign out: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final malls = ref.watch(mallsProvider);
    final shouldShowHomepage = ref.watch(shouldShowHomepageProvider);
    final selectedMallId = ref.watch(selectedMallIdProvider);
    final effectiveMall = ref.watch(effectiveMallProvider);
    final locationAsync = ref.watch(locationOnceProvider);

    // If effectiveMall is non-null → navigate automatically to MallView
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (effectiveMall != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MallView()),
        );
      }
    });

    // Show popup if there's a location error
    locationAsync.whenOrNull(
      data: (result) {
        if (result.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Location Error'),
                content: Text(result.error!),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          });
        }
      },
    );

    if (!shouldShowHomepage && effectiveMall != null) {
      // Navigate to MallView
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MallView()),
        );
      });
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // AppBar
          Container(
            height: kToolbarHeight,
            color: Colors.white,
            alignment: Alignment.center,
            child: const Text(
              'Syfepark',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),

          // Live Location with Sign Out button
          Container(
            color: backgroundColor,
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space out elements
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Live Location',
                      style: TextStyle(color: Colors.grey[800], fontSize: 16),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.grey),
                  tooltip: 'Sign Out',
                  onPressed: () => _signOut(context),
                ),
              ],
            ),
          ),

          // Mall Buttons (Manual Override)
          Container(
            color: backgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 10.0, left: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Where Do You want to Park?',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 80,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        MallButton(
                          icon: Icons.store,
                          label: 'RidgeWays Mall',
                          isSelected: selectedMallId == "ridgeways",
                          onTap: () =>
                              ref.read(selectedMallIdProvider.notifier).state =
                                  "ridgeways",
                        ),
                        const SizedBox(width: 12),
                        MallButton(
                          icon: Icons.store,
                          label: 'RNG Mall',
                          isSelected: selectedMallId == "rng",
                          onTap: () =>
                              ref.read(selectedMallIdProvider.notifier).state =
                                  "rng",
                        ),
                        const SizedBox(width: 12),
                        MallButton(
                          icon: Icons.store,
                          label: 'Mall 3',
                          isSelected: selectedMallId == "mall3",
                          onTap: () =>
                              ref.read(selectedMallIdProvider.notifier).state =
                                  "mall3",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content remains unchanged
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20.0),
                    child: Stack(
                      children: [
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage('assets/images/chill_photo.jpeg'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Text(
                              'Seamless Parking',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1.5, 1.5),
                                    blurRadius: 3.0,
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.grey, thickness: 0.5),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 10),
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
                              children: const [
                                ReusableAdCard(
                                  imagePath: 'assets/images/brand1.jpeg',
                                  description: '50% off on Delivery',
                                  url: 'https://www.promo.com',
                                ),
                                SizedBox(width: 12),
                                ReusableAdCard(
                                  imagePath: 'assets/images/brand2.jpeg',
                                  description: 'New Parking App Released',
                                  url: 'https://www.parkingapp.com',
                                ),
                                SizedBox(width: 12),
                                ReusableAdCard(
                                  imagePath: 'assets/images/brand3.jpeg',
                                  description: 'Shop & Win Coupons',
                                  url: 'https://www.shopandwin.com',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          Container(
            color: backgroundColor,
            padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FooterButton(
                  icon: Icons.home,
                  label: 'Home',
                  index: 0,
                  selectedIndex: _selectedIndex,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                FooterButton(
                  icon: Icons.local_parking,
                  label: 'Park',
                  index: 1,
                  selectedIndex: _selectedIndex,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                FooterButton(
                  icon: Icons.calendar_today,
                  label: 'Booking',
                  index: 2,
                  selectedIndex: _selectedIndex,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
                FooterButton(
                  icon: Icons.person,
                  label: 'My Account',
                  index: 3,
                  selectedIndex: _selectedIndex,
                  onTap: () => setState(() => _selectedIndex = 3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Mall Button modified to show selection
class MallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const MallButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue[300] : Colors.grey[200],
        foregroundColor: Colors.grey[800],
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }
}

// Footer Button
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

// Ad Card
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

  Future<void> _launchURL() async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _launchURL,
      child: Container(
        width: 200,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Rotated Image
            Transform.rotate(
              angle: 3.142, // 90 degrees in radians
              child: ClipRRect(
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