import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../routes/app_pages.dart';
class CuacaController extends GetxController {
  var hourlyForecast = <Map<String, String>>[].obs;
  var isLoading = true.obs;
  var kota = "Jember, Jawa Timur".obs;

  late String apiKey; // akan diisi dari config

  var historyList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadConfigAndFetch();
    listenToHistory();
  }

  Future<void> loadConfigAndFetch() async {
    try {
      final configString = await rootBundle.loadString('assets/config.json');
      final configData = json.decode(configString);
      apiKey = configData['apiKey'] ?? '';
    } catch (_) {
      apiKey = '';
    }

    await fetchForecast();
  }

  Future<void> fetchForecast() async {
    if (apiKey.isEmpty) {
      // Jika apiKey kosong, hentikan dan beri pesan biasa
      Get.snackbar("Gagal", "API key tidak tersedia");
      isLoading(false);
      return;
    }

    try {
      isLoading(true);
      final response = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?q=Jember&appid=$apiKey&units=metric",
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = (data['list'] as List).take(6).toList();

        hourlyForecast.value = list.map<Map<String, String>>((f) {
          final dt = DateTime.parse(f['dt_txt']);
          final time = "${dt.hour.toString().padLeft(2,'0')}:00";
          final temp = "${f['main']['temp'].round()}°C";

          final iconCode = f['weather'][0]['icon'];
          final iconEmoji = _mapIconCodeToEmoji(iconCode);

          return {
            'time': time,
            'temp': temp,
            'icon': iconEmoji,
          };
        }).toList();
      } else {
        // Gagal ambil data, tapi jangan tampilkan error detail
        Get.snackbar("Gagal", "Tidak dapat mengambil prakiraan cuaca");
      }
    } catch (_) {
      // Tangkap semua error tapi jangan tampilkan pesan teknis
      Get.snackbar("Gagal", "Terjadi kesalahan saat mengambil data");
    } finally {
      isLoading(false);
    }
  }

  void listenToHistory() {
    FirebaseFirestore.instance
        .collection('history')
        .orderBy('timestamp', descending: true)
        .limit(3)
        .snapshots()
        .listen((snapshot) {
      historyList.value = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'intensitas_cahaya': data['intensitas_cahaya'],
          'kelembaban': data['kelembaban'],
          'sensor_hujan': data['sensor_hujan'],
          'suhu': data['suhu'],
          'timestamp': data['timestamp'],
        };
      }).toList();
    }, onError: (e) {
      // Jangan tampilkan error ke UI, cukup log ke console
      print("Gagal mendengarkan data history: $e");
    });
  }

  String _mapIconCodeToEmoji(String code) {
    if (code.startsWith('01')) return '☀️';
    if (code.startsWith('02')) return '🌤️';
    if (code.startsWith('03') || code.startsWith('04')) return '☁️';
    if (code.startsWith('09') || code.startsWith('10')) return '🌧️';
    if (code.startsWith('11')) return '⛈️';
    if (code.startsWith('13')) return '❄️';
    if (code.startsWith('50')) return '🌫️';
    return '❓';
  }

  void keSetting() => Get.toNamed(Routes.SETTING);
  void keRiwayat() => Get.toNamed(Routes.HISTORY);
}
