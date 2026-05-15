import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {

  final double cpu = 85;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics Dashboard"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCharts(),
          const SizedBox(height: 20),
          _buildAlerts(),
          const SizedBox(height: 20),
          _buildMap(),
        ],
      ),
    );
  }

  /// =========================
  /// 📊 CHARTS
  /// =========================
  Widget _buildCharts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// TITLE + LEGEND
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "System Health",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  _legend(Colors.greenAccent, "CPU"),
                  const SizedBox(width: 10),
                  _legend(Colors.cyan, "Memory"),
                ],
              )
            ],
          ),

          const SizedBox(height: 20),

          /// CHART
          SizedBox(
            height: 160,
            child: Stack(
              children: [

                /// BAR CHART
                BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                    barGroups: [
                      _bar(0, 70, Colors.greenAccent),
                      _bar(1, 85, Colors.greenAccent),
                      _bar(2, 50, Colors.greenAccent),
                      _bar(3, 40, Colors.greenAccent),
                      _bar(4, 60, Colors.cyan),
                      _bar(5, 90, Colors.cyan),
                      _bar(6, 70, Colors.cyan),
                    ],
                  ),
                ),

                /// LINE CHART
                LineChart(
                  LineChartData(
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          FlSpot(0, 30),
                          FlSpot(1, 40),
                          FlSpot(2, 35),
                          FlSpot(3, 50),
                          FlSpot(4, 45),
                          FlSpot(5, 60),
                          FlSpot(6, 55),
                        ],
                        isCurved: true,
                        color: Colors.cyanAccent,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("CPU Usage", style: TextStyle(color: Colors.grey)),
              Text("Memory Load", style: TextStyle(color: Colors.grey)),
              Text("Network Traffic", style: TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  /// =========================
  /// 🤖 AI ALERT
  /// =========================
  Widget _buildAlerts() {
    if (cpu < 70) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "AI Alert: High CPU usage (${cpu.toInt()}%)",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// 🌍 MAP (RESPONSIVE FIX)
  /// =========================
  Widget _buildMap() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            children: [

              /// 🌍 BACKGROUND
              Positioned.fill(
                child: Opacity(
                  opacity: 0.25,
                  child: Image.asset(
                    "assets/images/world_map.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              /// 🔵 POINTS
              ..._buildPoints(width, height),
            ],
          );
        },
      ),
    );
  }

  /// 🌍 POINTS FIXED
  List<Widget> _buildPoints(double width, double height) {
    final points = [
      Offset(0.20, 0.42), // USA
      Offset(0.50, 0.35), // Europe
      Offset(0.52, 0.48), // Egypt
      Offset(0.75, 0.40), // Asia
      Offset(0.60, 0.65), // Africa
    ];

    return points.map((p) {
      return Positioned(
        left: p.dx * width,
        top: p.dy * height,
        child: _glowDot(),
      );
    }).toList();
  }

  /// 🔵 GLOW DOT
  Widget _glowDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.cyan,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withValues(alpha: 0.9),
            blurRadius: 18,
            spreadRadius: 4,
          ),
        ],
      ),
    );
  }

  /// =========================
  /// HELPERS
  /// =========================
  Widget _legend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 10,
          borderRadius: BorderRadius.circular(4),
        )
      ],
    );
  }
}