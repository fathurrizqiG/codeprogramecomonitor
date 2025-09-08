import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/grafik_controller.dart';

class GrafikView extends GetView<GrafikController> {
  const GrafikView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
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
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  Text(
                    'Grafik Harian',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48), // biar rata tengah
                ],
              ),
            ),

            const SizedBox(height: 16),

            Obx(() {
              if (controller.chartData.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              List<FlSpot> suhuSpots = [];
              List<FlSpot> kelembabanSpots = [];
              List<FlSpot> intensitasCahayaSpots = [];
              List<FlSpot> hujanSpots = [];

              for (int i = 0; i < controller.chartData.length; i++) {
                suhuSpots.add(FlSpot(i.toDouble(), controller.chartData[i]['suhu'] ?? 0.0));
                kelembabanSpots.add(FlSpot(i.toDouble(), controller.chartData[i]['kelembaban'] ?? 0.0));
                intensitasCahayaSpots.add(FlSpot(i.toDouble(), controller.chartData[i]['intensitas_cahaya'] ?? 0.0));
                hujanSpots.add(FlSpot(i.toDouble(), controller.chartData[i]['hujan'] ?? 0.0));
              }

              Widget buildChart(String title, List<FlSpot> spots, Color color,
                  {double? minY, double? maxY, bool isCurved = true, bool isHujan = false}) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 300,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: LineChart(
                          LineChartData(
                            minY: minY ?? 0,
                            maxY: maxY,
                            gridData: FlGridData(show: true, drawVerticalLine: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: isHujan ? 1 : 20,
                                  getTitlesWidget: (value, meta) {
                                    if (isHujan) {
                                      if (value == 0) return const Text("Tidak Hujan", style: TextStyle(fontSize: 8));
                                      if (value == 1) return const Text("Hujan", style: TextStyle(fontSize: 8));
                                    }
                                    return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= 0 && value.toInt() < controller.chartData.length) {
                                      var timestamp = controller.chartData[value.toInt()]['timestamp'];
                                      if (timestamp != null) {
                                        String hour = timestamp.hour.toString().padLeft(2, '0');
                                        String minute = timestamp.minute.toString().padLeft(2, '0');
                                        return Text("$hour:$minute", style: const TextStyle(fontSize: 10));
                                      }
                                    }
                                    return const Text("");
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: const Border(
                                left: BorderSide(color: Colors.black),
                                bottom: BorderSide(color: Colors.black),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: isCurved,
                                color: color,
                                barWidth: 2,
                                dotData: FlDotData(show: !isHujan ? false : true),
                                belowBarData: BarAreaData(show: true, color: color.withOpacity(0.15)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }

              return Column(
                children: [
                  buildChart("Grafik Suhu", suhuSpots, Colors.blue),
                  buildChart("Grafik Kelembaban", kelembabanSpots, Colors.green),
                  buildChart("Grafik Intensitas Cahaya", intensitasCahayaSpots, Colors.orange),
                  buildChart("Grafik Hujan", hujanSpots, Colors.purple, minY: 0, maxY: 1, isCurved: false, isHujan: true),
                ],
              );
            }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
