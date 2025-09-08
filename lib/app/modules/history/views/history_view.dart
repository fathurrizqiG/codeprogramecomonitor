import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: size.width,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7AD6F0), Color(0xFF51C3E8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  Center(
                    child: Text(
                      'History Data',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        popupMenuTheme: PopupMenuThemeData(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          textStyle: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                          elevation: 10,
                        ),
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) {
                          if (value == 'download') {
                            controller.downloadPDF();
                          } else if (value == 'delete') {
                            controller.deleteAllData();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'download',
                            child: Row(
                              children: const [
                                Icon(Icons.download_rounded, color: Colors.blueAccent),
                                SizedBox(width: 10),
                                Text('Download PDF'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: const [
                                Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                                SizedBox(width: 10),
                                Text('Hapus Semua Data'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Area scrollable seluruh isi
            Expanded(
              child: Obx(() {
                final docs = controller.historyDocs;

                if (controller.isLoading && docs.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (docs.isEmpty) {
                  return const Center(child: Text('Tidak ada data.'));
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 800,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                color: Colors.grey[200],
                                child: Row(
                                  children: [
                                    _headerCell('Timestamp', 180),
                                    _headerCell('Suhu (°C)', 100),
                                    _headerCell('Kelembaban (%)', 130),
                                    _headerCell('Intensitas (lux)', 120),
                                    _headerCell('Sensor Hujan', 130),
                                  ],
                                ),
                              ),

                              ...docs.asMap().entries.map((entry) {
                                final index = entry.key;
                                final data = entry.value.data() as Map<String, dynamic>;

                                return Container(
                                  color: index % 2 == 0
                                      ? Colors.grey.shade100
                                      : Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      _dataCell(controller.formatTimestamp(data['timestamp']), 180),
                                      _dataCell('${data['suhu'] ?? '-'}', 100),
                                      _dataCell('${data['kelembaban'] ?? '-'}', 130),
                                      _dataCell('${data['intensitas_cahaya'] ?? '-'}', 120),
                                      _dataCell(controller.formatSensorHujan(data['sensor_hujan']), 130),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: controller.currentPage > 1
                                  ? controller.previousPage
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: controller.currentPage > 1
                                    ? const Color(0xFF51C3E8)
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Previous"),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              'Page ${controller.currentPage}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: controller.hasMore ? controller.nextPage : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: controller.hasMore
                                    ? const Color(0xFF51C3E8)
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Next"),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String label, double width) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _dataCell(String value, double width) {
    return SizedBox(
      width: width,
      child: Text(
        value,
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
      ),
    );
  }
}
