import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navbar_controller.dart';
import '../../home/views/home_view.dart';
import '../../cuaca/views/cuaca_view.dart';

class NavbarView extends StatelessWidget {
  const NavbarView({super.key});

  @override
  Widget build(BuildContext context) {
    final NavbarController controller = Get.find<NavbarController>();

    final List<Widget> pages = const [
      HomeView(),
      CuacaView(),
    ];

    return Obx(() => Scaffold(
          body: IndexedStack(
            index: controller.selectedIndex.value,
            children: pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.selectedIndex.value,
            onTap: controller.changeTabIndex,
            backgroundColor: const Color(0xFF7AD6F0),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.cloud),
                label: 'Cuaca',
              ),
            ],
          ),
        ));
  }
}
