import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GrafikController extends GetxController {
  var chartData = <Map<String, dynamic>>[].obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _listenToDailyData();
  }

  // Dengarkan data real-time dari Firestore
  void _listenToDailyData() {
    _firestore
        .collection('history')
        .orderBy('timestamp', descending: true)
        .limit(30) // ambil 30 data terakhir
        .snapshots()
        .listen((snapshot) {
      chartData.value = snapshot.docs.map((doc) {
        var data = doc.data();
        return {
          'suhu': (data['suhu'] ?? 0.0).toDouble(),
          'kelembaban': (data['kelembaban'] ?? 0.0).toDouble(),
          'intensitas_cahaya': (data['intensitas_cahaya'] ?? 0.0).toDouble(),
          'hujan': (data['hujan'] == 'Hujan') ? 1.0 : 0.0,
          'timestamp': data['timestamp'] is Timestamp
              ? (data['timestamp'] as Timestamp).toDate()
              : null,
        };
      }).toList().reversed.toList(); // dibalik biar data terlama ke terbaru
    });
  }
}
