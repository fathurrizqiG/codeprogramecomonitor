import 'package:get/get.dart';
import '../controllers/navbar_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../cuaca/controllers/cuaca_controller.dart';

class NavbarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavbarController>(() => NavbarController());
    Get.lazyPut<HomeController>(() => HomeController());    // Tambah ini
    Get.lazyPut<CuacaController>(() => CuacaController());  // Tambah ini
  }
}
