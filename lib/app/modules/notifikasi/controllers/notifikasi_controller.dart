import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class NotifikasiController extends GetxController {
  final notifikasiList = <Map<String, dynamic>>[].obs;
  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  void loadNotifications() {
    final data = storage.read<List>('notification_history');
    if (data != null) {
      final sorted = List<Map<String, dynamic>>.from(data.reversed);
      notifikasiList.value = sorted.where((item) =>
        item['waktu'] != null &&
        item['judul'] != null &&
        item['deskripsi'] != null
      ).toList();
    }
  }

  void hapusNotifikasi(String waktu) {
    final updatedList = List<Map<String, dynamic>>.from(notifikasiList);
    updatedList.removeWhere((item) => item['waktu'] == waktu);
    notifikasiList.value = updatedList;

    // Simpan ke storage
    storage.write('notification_history', updatedList.reversed.toList());
  }

  void hapusSemua() {
  notifikasiList.clear();
  storage.write('notification_history', []);
}

}
