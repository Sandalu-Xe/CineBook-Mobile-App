import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color bgPurple = Color(0xFF1A0B2E);
    const Color brightPurple = Color(0xFF6100FF);
    const Color textHighlight = Color(0xFF9D4EDD);

    return Scaffold(
      backgroundColor: bgPurple,
      body: Stack(
        children: [
          // Background subtle grid and circles (Mocked with simple circles)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.05), width: 2),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.05), width: 2),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: brightPurple,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.movie_creation,
                        color: AppColors.secondary,
                        size: 48,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // CineBook Logo Text
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1),
                    children: [
                      TextSpan(text: 'Cine', style: TextStyle(color: Colors.white)),
                      TextSpan(text: 'Book', style: TextStyle(color: AppColors.secondary)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Tagline
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
                    children: [
                      TextSpan(text: 'Book tickets '),
                      TextSpan(text: 'together', style: TextStyle(color: textHighlight, fontWeight: FontWeight.bold)),
                      TextSpan(text: ',\npay '),
                      TextSpan(text: 'separately', style: TextStyle(color: textHighlight, fontWeight: FontWeight.bold)),
                      TextSpan(text: '.'),
                    ],
                  ),
                ),
                
                const Spacer(flex: 2),
                
                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ElevatedButton(
                    onPressed: () => context.push('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brightPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: OutlinedButton(
                    onPressed: () => context.go('/home'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFF25183A),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.transparent),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Browse as Guest', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                ),
                
                const Spacer(),
                
                // Trending Now
                const Text(
                  'TRENDING NOW',
                  style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: textHighlight, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: textHighlight, shape: BoxShape.circle)),
                  ],
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
