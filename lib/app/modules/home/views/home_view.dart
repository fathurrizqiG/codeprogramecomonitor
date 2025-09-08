import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat("EEEE, d MMMM yyyy", "id_ID").format(now);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Jember, Jawa Timur",
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(formattedDate,
                                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications, color: Colors.white),
                          onPressed: controller.keNotifikasi,
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Koneksi alat
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              controller.koneksiAlat.value ? const Color(0xFF51C3E8) : Colors.red,
                          radius: 24,
                          child: const Icon(Icons.sync, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Koneksi Alat",
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                            Text(
                              controller.koneksiAlat.value ? "Connect" : "Disconnect",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: controller.koneksiAlat.value
                                    ? const Color(0xFF51C3E8)
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Kartu suhu
                  Container(
                    width: size.width - 40,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7AD6F0), Color(0xFF51C3E8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.thermostat_outlined, color: Colors.white, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          "${controller.suhu.value.toStringAsFixed(1)}ºC",
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text("Suhu",
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Kelembaban, Intensitas Cahaya, Sensor Hujan
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: size.width > 600
                        ? Row(
                            children: [
                              Expanded(
                                child: _miniCard(
                                    Icons.water_drop,
                                    "${controller.kelembaban.value.toStringAsFixed(0)}%",
                                    "Kelembaban"),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _miniCard(
                                    Icons.wb_sunny,
                                    "${controller.intensitasCahaya.value.toStringAsFixed(0)} LUX",
                                    "Intensitas Cahaya"),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _miniCard(
                                    Icons.grain,
                                    controller.sensorHujan.value.isEmpty
                                        ? "Tidak Ada Data"
                                        : controller.sensorHujan.value,
                                    "Sensor Hujan"),
                              ),
                            ],
                          )
                        : Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              SizedBox(
                                width: (size.width - 60) / 3,
                                child: _miniCard(
                                    Icons.water_drop,
                                    "${controller.kelembaban.value.toStringAsFixed(0)}%",
                                    "Kelembaban"),
                              ),
                              SizedBox(
                                width: (size.width - 60) / 3,
                                child: _miniCard(
                                    Icons.wb_sunny,
                                    "${controller.intensitasCahaya.value.toStringAsFixed(0)} LUX",
                                    "Intensitas Cahaya"),
                              ),
                              SizedBox(
                                width: (size.width - 60) / 3,
                                child: _miniCard(
                                    Icons.grain,
                                    controller.sensorHujan.value.isEmpty
                                        ? "Tidak Ada Data"
                                        : controller.sensorHujan.value,
                                    "Sensor Hujan"),
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 20),
// Grafik & Analisis
Container(
  margin: const EdgeInsets.symmetric(horizontal: 20),
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: const Color(0xFF7AD6F0),  // Background biru muda
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.transparent), // Border transparan
  ),
  child: ElevatedButton(
    onPressed: controller.keGrafik,  // Function from controller
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,  // Transparan untuk button
      shadowColor: Colors.transparent,
      padding: EdgeInsets.zero,
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,  // Warna putih untuk CircleAvatar
          radius: 24,
          child: const Icon(Icons.show_chart, color: Color(0xFF7AD6F0)),  // Ikon biru
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Grafik & Analisis", 
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500, 
                color: Colors.white,  // Warna teks tetap putih
              ),
            ),
            Text(
              "Lihat Grafik",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,  // Warna teks tetap putih
              ),
            ),
          ],
        ),
      ],
    ),
  ),
)


                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _miniCard(IconData icon, String value, String label) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF7AD6F0), Color(0xFF51C3E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          Text(label, style: GoogleFonts.poppins(color: Colors.white, fontSize: 8)),
        ],
      ),
    );
  }
}
