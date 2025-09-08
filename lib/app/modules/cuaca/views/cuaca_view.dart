import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/cuaca_controller.dart';

class CuacaView extends GetView<CuacaController> {
  const CuacaView({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat("EEEE, d MMMM yyyy", "id_ID").format(now);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === HEADER ===
              Container(
                width: size.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7AD6F0), Color(0xFF51C3E8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => Text(
                                controller.kota.value,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                          const SizedBox(height: 4),
                          Text(
                            formattedDate,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: controller.keSetting,
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // === PRAKIRAAN CUACA ===
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.hourlyForecast.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Prakiraan cuaca tidak tersedia"),
                  );
                }

                return Container(
                  color: const Color(0xFF7AD6F0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: controller.hourlyForecast.map((f) {
                        return Container(
                          width: 70,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                f['time'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                f['icon'] ?? '',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                f['temp'] ?? '',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // === HISTORY HEADER ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'History Data',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.keRiwayat,
                      child: Text(
                        'Selengkapnya',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // === HISTORY LIST dari Firestore ===
              Obx(() {
                final history = controller.historyList;
                if (history.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Belum ada data histori."),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = history[index];
                    final timestamp = item['timestamp'];
                    final dateFormatted = timestamp != null
                        ? DateFormat('dd MMM yyyy HH:mm')
                            .format(timestamp.toDate())
                        : '-';

                    final hujanText =
                        (item['sensor_hujan'] ?? false) ? "Hujan" : "Tidak Hujan";

                    final details =
                        "Suhu: ${item['suhu']}°C, Kelembaban: ${item['kelembaban']}%, IC: ${item['intensitas_cahaya']} Lux, $hujanText";

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Kondisi Lingkungan'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(details),
                          const SizedBox(height: 2),
                          Text(
                            dateFormatted,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    );
                  },
                );
              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
