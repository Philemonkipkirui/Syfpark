// lib/views/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syfpark/views/home/constants.dart';
import 'package:syfpark/services/providers.dart';
import 'package:syfpark/views/Mall/mall_view.dart';
import 'package:syfpark/views/landing/landing_page.dart';
import 'package:syfpark/views/user/profile_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  bool _hasNavigated = false; // Prevent multiple location-based navigations

Future<void> _signOut(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  } catch (e) {
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
  void initState() {
    super.initState();
    // Reset navigation flag when HomePage is initialized
    _hasNavigated = false;
  }

  @override
  Widget build(BuildContext context) {
    final malls = ref.watch(mallsProvider);
    final shouldShowHomepage = ref.watch(shouldShowHomepageProvider);
    final selectedMallId = ref.watch(selectedMallIdProvider);
    final effectiveMall = ref.watch(effectiveMallProvider);
    final locationAsync = ref.watch(locationOnceProvider);

    // Handle location errors
    locationAsync.whenOrNull(
      data: (result) {
        if (result.error != null && context.mounted) {
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

    // Location-based navigation (only once)
    if (!shouldShowHomepage && effectiveMall != null && !_hasNavigated) {
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('Navigating to MallView for ${effectiveMall.name} (location-based)'); // Debug
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MallView()),
        );
      });
    }
    
    return Scaffold(
      backgroundColor: AppColors.background, // White (#FFFFFF)
      body: Column(
        children: [
          Container(
            height: kToolbarHeight,
            decoration: BoxDecoration(
              color: AppColors.background, // White
              border: Border(bottom: BorderSide(color: AppColors.border)), // Grey 800 (#424242)
            ),
            alignment: Alignment.center,
            child: Text(
              'Syfepark',
              style: Theme.of(context).textTheme.headlineMedium, // Orbitron, #212121, bold, 20px
            ),
          ),
          Container(
            color: AppColors.background, // White
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.textUnselected), // #757575
                    const SizedBox(width: 8),
                    Text(
                      'Live Location',
                      style: Theme.of(context).textTheme.bodyMedium, // #424242, 16px
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: AppColors.textUnselected), // Grey 100 (#F5F5F5)
                  tooltip: 'Sign Out',
                  onPressed: () => _signOut(context),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.textSecondary, thickness: 0.5),
          Container(
            color: AppColors.background, // White
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10.0, left: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Where Do You Want to Park?',
                      style: Theme.of(context).textTheme.headlineMedium, // #212121, bold, 20px
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
                          onTap: () {
                            ref.read(selectedMallIdProvider.notifier).state = "ridgeways";
                            print('Navigating to MallView for RidgeWays Mall'); // Debug
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MallView()),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        MallButton(
                          icon: Icons.store,
                          label: 'RNG Mall',
                          isSelected: selectedMallId == "rng",
                          onTap: () {
                            ref.read(selectedMallIdProvider.notifier).state = "rng";
                            print('Navigating to MallView for RNG Mall'); // Debug
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MallView()),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        MallButton(
                          icon: Icons.store,
                          label: 'Mall 3',
                          isSelected: selectedMallId == "mall3",
                          onTap: () {
                            ref.read(selectedMallIdProvider.notifier).state = "mall3";
                            print('Navigating to MallView for Mall 3'); // Debug
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MallView()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
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
                            border: Border.all(color: AppColors.border), // Grey 800 (#424242)
                          ),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Text(
                              'Seamless Parking',
                              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                    color: AppColors.textOverlay, // White (#FFFFFF)
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
                  const Divider(color: AppColors.textSecondary, thickness: 0.5), // Grey 800 (#424242)
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.buttonSelected, // Grey 500 (#757575)
                  AppColors.buttonSelected.withOpacity(0.8),
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
                  onTap: () {
                    setState(() => _selectedIndex = 3);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  },
                ),  
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.buttonSelected : AppColors.buttonUnselected, // #757575 or #FAFAFA
          foregroundColor: AppColors.textSecondary, // #424242
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.border), // Grey 800 (#424242)
          ),
          elevation: isSelected ? 4 : 2,
          shadowColor: AppColors.accent.withOpacity(0.3), // Grey 100 (#F5F5F5)
        ),
        onPressed: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 6),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  AppColors.buttonSelected, // Grey 500 (#757575)
                  AppColors.buttonSelected.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : AppColors.buttonUnselected, // Grey 50 (#FAFAFA)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border), // Grey 800 (#424242)
        boxShadow: [
          BoxShadow(
            color: isSelected ? AppColors.accent.withOpacity(0.3) : Colors.transparent, // Grey 100 (#F5F5F5)
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
              color: isSelected ? AppColors.textSecondary : AppColors.textUnselected, // #424242 or #757575
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
            border: Border.all(color: AppColors.border), // Grey 800 (#424242)
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
                          color: AppColors.textOverlay, // White (#FFFFFF)
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