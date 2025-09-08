import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final suhu = 0.0.obs;
  final kelembaban = 0.0.obs;
  final intensitasCahaya = 0.0.obs;
  final sensorHujan = ''.obs; // ← string bukan bool
  final koneksiAlat = true.obs;

  final suhuThreshold = 35.0.obs;
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final box = GetStorage();

  final database = FirebaseDatabase.instance.ref();
  DateTime lastDataTime = DateTime.now();

  bool suhuNotifSent = false;
  bool hujanNotifSent = false;

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
    _listenToSensorData();
    _startTimeoutCheck();
  }

  void _initNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initSettings = InitializationSettings(android: androidInit);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  void _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Peringatan',
      channelDescription: 'Notifikasi penting',
      importance: Importance.max,
      priority: Priority.high,
    );
    const platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
    );

    _saveNotificationToStorage(title, body);
  }

  void _saveNotificationToStorage(String title, String body) {
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final List history = box.read('notification_history') ?? [];

    history.add({'judul': title, 'deskripsi': body, 'waktu': now});
    box.write('notification_history', history);
  }

  void _listenToSensorData() {
    // Listen to threshold changes
    database.child('threshold/suhu').onValue.listen((event) {
      final value = event.snapshot.value;
      if (value is num) suhuThreshold.value = value.toDouble();
    });

    // Listen to sensor data
    database.child('sensor').onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

      lastDataTime = DateTime.now();
      koneksiAlat.value = true;

      suhu.value = (data['suhu'] ?? 0).toDouble();
      kelembaban.value = (data['kelembaban'] ?? 0).toDouble();
      intensitasCahaya.value = (data['intensitas_cahaya'] ?? 0).toDouble();
      sensorHujan.value = data['sensor_hujan']?.toString() ?? '';

      // Handle suhu notification
      if (suhu.value > suhuThreshold.value && !suhuNotifSent) {
        _showNotification("Suhu Tinggi", "Suhu melebihi batas: ${suhuThreshold.value}°C");
        suhuNotifSent = true;
      } else if (suhu.value <= suhuThreshold.value) {
        suhuNotifSent = false;
      }

      // Handle hujan notification (jika bukan "Cerah" maka dianggap hujan)
      if (sensorHujan.value != "Cerah" && !hujanNotifSent) {
        _showNotification("Hujan Terdeteksi", "Sensor mendeteksi hujan (${sensorHujan.value}).");
        hujanNotifSent = true;
      } else if (sensorHujan.value == "Cerah") {
        hujanNotifSent = false;
      }
    });
  }

  void _startTimeoutCheck() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      final diff = DateTime.now().difference(lastDataTime);

      if (diff.inSeconds >= 120 && koneksiAlat.value) {
        koneksiAlat.value = false;
        _showNotification(
          "Koneksi Terputus",
          "Tidak ada data baru selama 2 menit. Periksa koneksi alat.",
        );
      }
      return true;
    });
  }

  void keNotifikasi() => Get.toNamed(Routes.NOTIFIKASI);
  void keGrafik() => Get.toNamed(Routes.GRAFIK);
}
