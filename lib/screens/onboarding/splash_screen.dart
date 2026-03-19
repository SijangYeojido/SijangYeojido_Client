import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 1.8s delay for an official, solid brand intro
    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Official 3D Pin (With enhanced filtering for perfect white transparency)
            // Using matrix to blow out any non-pure-white grey background before multiply
            ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.multiply),
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  1.1, 0, 0, 0, -10, // Lighten and clip blacks
                  0, 1.1, 0, 0, -10,
                  0, 0, 1.1, 0, -10,
                  0, 0, 0, 1, 0,
                ]),
                child: Hero(
                  tag: 'app_logo_hero',
                  child: Image.file(
                    File('/Users/bagjun-won/.gemini/antigravity/brain/e15396eb-f0dd-4d64-b358-ea947342e98d/hero_3d_pin.png'),
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            
            // 2. Official Brand Branding "시장여지도" (Now in Brand Red)
            const Text(
              '시장여지도',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: AppColors.primary, // Official Hong-saek (Traditional Red)
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(height: 12),
            
            // 3. Official Slogan (Now in Brand Red)
            const Text(
              '시장에 가고 싶을 때',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary, // Brand Alignment
                letterSpacing: -0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
