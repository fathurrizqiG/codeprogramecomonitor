import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_screen_controller.dart';

class SplashScreenView extends StatelessWidget {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final SplashScreenController controller = Get.put(SplashScreenController());

    return Scaffold(
      backgroundColor: const Color(0xFF7AD6F0), // Warna biru muda (light blue)
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud, // Ikon yang sesuai untuk tema lingkungan
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'EcoMonitor',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pantau Kebunmu Secara Cerdas\nKapan Saja dan di Mana Saja',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
