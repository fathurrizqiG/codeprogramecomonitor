import 'package:get/get.dart';

import '../controllers/cuaca_controller.dart';

class CuacaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CuacaController>(
      () => CuacaController(),
    );
  }
}
