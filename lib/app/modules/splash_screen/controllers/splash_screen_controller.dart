import 'package:get/get.dart';
import 'package:ecomoni/app/routes/app_pages.dart'; // Sesuaikan dengan nama project kamu

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 5), () {
      Get.offAllNamed(Routes.NAVBAR); // atau Routes.NAVBAR jika kamu punya bottom nav
    });
  }
}
