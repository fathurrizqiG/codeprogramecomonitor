import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';

class SettingController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final thresholdController = TextEditingController();
  final intervalController = TextEditingController();
  final suhuController = TextEditingController();

  final database = FirebaseDatabase.instance.ref();

  @override
  void onInit() {
    super.onInit();
    ambilDataDariFirebase();
  }

  void ambilDataDariFirebase() async {
    final snapshot = await database.child("threshold").get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      intervalController.text = data['interval'].toString();
      suhuController.text = data['suhu'].toString();
    }
  }

  void simpanKeFirebase() {
    if (formKey.currentState?.validate() != true) return;

    final data = {
      "interval": int.tryParse(intervalController.text) ?? 0,
      "suhu": int.tryParse(suhuController.text) ?? 0,
    };

    database.child("threshold").set(data).then((_) {
      Get.snackbar("Berhasil", "Pengaturan berhasil disimpan",
          snackPosition: SnackPosition.BOTTOM);
    }).catchError((e) {
      Get.snackbar("Gagal", "Terjadi kesalahan saat menyimpan",
          snackPosition: SnackPosition.BOTTOM);
    });
  }

  @override
  void onClose() {
    thresholdController.dispose();
    intervalController.dispose();
    suhuController.dispose();
    super.onClose();
  }
}
