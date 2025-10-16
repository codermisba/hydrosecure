import 'package:flutter/material.dart';
import 'package:hydrosecure/theme.dart';

class AnalyticsDashboardPage extends StatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  State<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends State<AnalyticsDashboardPage> {
  final List<String> rivers = [
    "Ganga",
    "Yamuna",
    "Godavari",
    "Krishna",
    "Narmada",
    "Cauvery",
    "Brahmaputra",
    "Tapti",
    "Mahanadi",
    "Sabarmati",
  ];

  String? selectedRiver;

  // Static demo values
  final double waterLevel = 14.0;
  final double streamFlow = 41.0;
  final double temperature = 28.0;
  final double turbidity = 5.2;
  final double rainfall = 70.0;

  Widget _buildStatCard(
      {required String title,
      required String value,
      required IconData icon,
      required List<Color> gradientColors}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
          ],
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics Dashboard"),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // River Dropdown
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedRiver,
                    hint: const Text("Select River"),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    items: rivers.map((river) {
                      return DropdownMenuItem<String>(
                        value: river,
                        child: Text(river,
                            style: const TextStyle(fontSize: 16)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRiver = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: selectedRiver == null
                  ? const Center(
                      child: Text(
                        "Select a river to view analytics",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            "$selectedRiver River Analytics",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildStatCard(
                                  title: "Water Level",
                                  value: "$waterLevel m",
                                  icon: Icons.water_drop,
                                  gradientColors: [
                                    Colors.blue.shade400,
                                    Colors.blue.shade800
                                  ]),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                  title: "Stream Flow",
                                  value: "$streamFlow m³/s",
                                  icon: Icons.waves,
                                  gradientColors: [
                                    Colors.green.shade400,
                                    Colors.green.shade800
                                  ]),
                            ],
                          ),
                          Row(
                            children: [
                              _buildStatCard(
                                  title: "Temperature",
                                  value: "$temperature °C",
                                  icon: Icons.thermostat,
                                  gradientColors: [
                                    Colors.red.shade400,
                                    Colors.red.shade700
                                  ]),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                  title: "Turbidity",
                                  value: "$turbidity NTU",
                                  icon: Icons.blur_on,
                                  gradientColors: [
                                    Colors.orange.shade400,
                                    Colors.orange.shade700
                                  ]),
                            ],
                          ),
                          Row(
                            children: [
                              _buildStatCard(
                                  title: "Rainfall",
                                  value: "$rainfall mm",
                                  icon: Icons.cloud,
                                  gradientColors: [
                                    Colors.indigo.shade400,
                                    Colors.indigo.shade800
                                  ]),
                              const SizedBox(width: 12),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
