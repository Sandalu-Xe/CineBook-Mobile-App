import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
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
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.movie_creation,
                        color: Theme.of(context).colorScheme.primary,
                        size: 48,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1, color: Theme.of(context).colorScheme.onPrimary),
                    children: [
                      const TextSpan(text: 'Cine'),
                      TextSpan(text: 'Book', style: TextStyle(color: Theme.of(context).colorScheme.secondaryContainer)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8), height: 1.5),
                    children: [
                      const TextSpan(text: 'Book tickets '),
                      TextSpan(text: 'together', style: TextStyle(color: Theme.of(context).colorScheme.secondaryContainer, fontWeight: FontWeight.bold)),
                      const TextSpan(text: ',\npay '),
                      TextSpan(text: 'separately', style: TextStyle(color: Theme.of(context).colorScheme.secondaryContainer, fontWeight: FontWeight.bold)),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: FilledButton.icon(
                    onPressed: () => context.push('/login'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: OutlinedButton(
                    onPressed: () => context.go('/home'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      side: BorderSide(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.5)),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: const Text('Browse as Guest', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                ),
                const Spacer(),
                Text(
                  'TRENDING NOW',
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.4), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.4), shape: BoxShape.circle)),
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
