import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syfpark/views/home/constants.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background, // White (#FFFFFF)
      appBar: AppBar(
        backgroundColor: AppColors.background, // White
        elevation: 0,
        title: Text(
          'My Account',
          style: Theme.of(context).textTheme.headlineMedium, // Orbitron, #212121, bold, 20px
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textSecondary), // #424242
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(color: AppColors.border, height: 1), // Grey 800 (#424242)
        ),
      ),
      body: SafeArea(
        child: user == null
            ? const Center(
                child: Text(
                  'No user signed in',
                  style: TextStyle(
                    color: AppColors.textSecondary, // #424242
                    fontSize: 16,
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading profile: ${snapshot.error}',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(
                        child: Text(
                          'Profile data not found',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final name = data['displayName'] ?? user.displayName ?? 'Anonymous';
                    final email = data['email'] ?? user.email ?? 'No email';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Header
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.buttonSelected, // Grey 500 (#757575)
                                backgroundImage: user.photoURL != null
                                    ? NetworkImage(user.photoURL!)
                                    : null,
                                child: user.photoURL == null
                                    ? Icon(
                                        Icons.person,
                                        size: 50,
                                        color: AppColors.textOverlay, // White (#FFFFFF)
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // User Information
                        _buildInfoCard(
                          context,
                          icon: Icons.person,
                          label: 'Name',
                          value: name,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          context,
                          icon: Icons.email,
                          label: 'Email',
                          value: email,
                        ),
                        const Spacer(),
                        // Sign Out Button
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                await FirebaseAuth.instance.signOut();
                                Navigator.pushReplacementNamed(context, '/');
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Sign out failed: $e')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.textOverlay, // Grey 500 (#757575)
                              foregroundColor: AppColors.textUnselected, // White (#FFFFFF)
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: AppColors.border), // Grey 800 (#424242)
                              ),
                            ),
                            child: const Text(
                              'Sign Out',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.buttonUnselected, // Grey 50 (#FAFAFA)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border), // Fixed: Use Border.all instead of BorderSide
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3), // Grey 100 (#F5F5F5)
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 24), // #424242
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: AppColors.textUnselected, // #757575
                      fontSize: 14,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.textPrimary, // #212121
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}