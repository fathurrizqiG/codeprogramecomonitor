import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<DocumentSnapshot> historyDocs = <DocumentSnapshot>[].obs;
  final int limit = 10;

  DocumentSnapshot? lastDocument;
  DocumentSnapshot? firstDocument;
  bool hasMore = true;
  bool isLoading = false;

  int currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    fetchData(isInitial: true);
  }

  void fetchData({bool isNext = true, bool isInitial = false}) async {
    if (isLoading) return;
    isLoading = true;

    Query query = _firestore
        .collection('history')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (isNext && lastDocument != null && !isInitial) {
      query = query.startAfterDocument(lastDocument!);
    } else if (!isNext && firstDocument != null) {
      query = query.endBeforeDocument(firstDocument!).limitToLast(limit);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      if (isNext && !isInitial) currentPage++;
      if (!isNext && currentPage > 1) currentPage--;

      historyDocs.value = snapshot.docs;
      firstDocument = snapshot.docs.first;
      lastDocument = snapshot.docs.last;
      hasMore = snapshot.docs.length == limit;
    }

    isLoading = false;
  }

  void nextPage() => fetchData(isNext: true);
  void previousPage() => fetchData(isNext: false);

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '-';
    final date = timestamp.toDate();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return "$day/$month/$year $hour:$minute";
  }

  String formatSensorHujan(dynamic value) {
    if (value == true) return 'Hujan';
    if (value == false) return 'Tidak Hujan';
    return '-';
  }

  Future<void> downloadPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Data History', style: pw.TextStyle(fontSize: 24)),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Timestamp', 'Suhu (°C)', 'Kelembaban (%)', 'Intensitas', 'Sensor Hujan'],
            data: historyDocs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return [
                formatTimestamp(data['timestamp']),
                data['suhu']?.toString() ?? '-',
                data['kelembaban']?.toString() ?? '-',
                data['intensitas_cahaya']?.toString() ?? '-',
                formatSensorHujan(data['sensor_hujan']),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> deleteAllData() async {
    final snapshots = await _firestore.collection('history').get();
    for (final doc in snapshots.docs) {
      await doc.reference.delete();
    }
    fetchData(isInitial: true);
    Get.snackbar("Berhasil", "Semua data berhasil dihapus.");
  }
}
