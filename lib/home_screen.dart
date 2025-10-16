import 'package:flutter/material.dart';
import 'package:hydrosecure/analytics_page.dart';
import 'package:hydrosecure/profile_page.dart';
import 'package:hydrosecure/river_details_screen.dart';
import 'package:hydrosecure/theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'upload_reading_page.dart';
import 'package:hydrosecure/river_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  String? selectedRiver; // nullable, initially no river selected

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      debugPrint("✅ Location permission granted");
    } else if (status.isDenied) {
      debugPrint("⚠️ Location permission denied");
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  void _openRiverMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RiverMapScreen()),
    );
  }

  void _openAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalyticsDashboardPage(
           // pass selected river (can be null)
        ),
      ),
    );
  }

  void _openRiverDetails(String riverName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RiverDetailScreen(riverName: riverName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HydroSecure"),
        backgroundColor: primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 28),
            tooltip: 'Profile',
            onPressed: () {
              // Navigate to ProfilePage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _openRiverMap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.explore, size: 60, color: Colors.blue),
                            SizedBox(height: 12),
                            Text(
                              "River Map",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Card(
                    color: Colors.orange.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _openAnalytics,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.analytics,
                              size: 60,
                              color: Colors.orange,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Analytics",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              "Select a River",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: rivers.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.water_drop, color: Colors.blue),
                      title: Text(
                        rivers[index],
                        style: const TextStyle(fontSize: 18),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        setState(() {
                          selectedRiver = rivers[index]; // store selected river
                        });
                        _openRiverDetails(rivers[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
