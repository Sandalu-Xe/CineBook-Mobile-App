import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../models/core_models.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'custom_navigation_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profile = await DatabaseService().getUserProfile(user.uid);
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: 2),
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : _userProfile == null 
          ? const Center(child: Text("No Profile Found. Please sign in.")) 
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                        child: Text(
                          _userProfile!.fullName.isNotEmpty ? _userProfile!.fullName[0].toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _userProfile!.fullName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userProfile!.email,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 32),
                      Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.phone, color: Theme.of(context).colorScheme.primary),
                              title: const Text('Phone Number'),
                              subtitle: Text(_userProfile!.phone.isNotEmpty ? _userProfile!.phone : 'Not provided'),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                              title: const Text('Member Since'),
                              subtitle: Text('${_userProfile!.createdAt.year}-${_userProfile!.createdAt.month.toString().padLeft(2, '0')}-${_userProfile!.createdAt.day.toString().padLeft(2, '0')}'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.tonalIcon(
                          onPressed: () async {
                            await AuthService().signOut();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign Out'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.errorContainer,
                            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
