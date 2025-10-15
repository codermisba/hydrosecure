import 'package:flutter/material.dart';
import 'package:hydrosecure/profile_page.dart';
import 'package:hydrosecure/theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'upload_reading_page.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Map feature coming soon! 🌍"),
        behavior: SnackBarBehavior.floating,
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
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.explore, size: 80, color: primaryColor),
                  onPressed: _openRiverMap,
                ),
                const Text(
                  "View India River Map",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
              ],
            ),
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
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.water_drop, color: Colors.blue),
                      title: Text(
                        rivers[index],
                        style: const TextStyle(fontSize: 18),
                      ),
                      trailing:
                          const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                      onTap: () => _openRiverDetails(rivers[index]),
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

class RiverDetailScreen extends StatelessWidget {
  final String riverName;
  const RiverDetailScreen({super.key, required this.riverName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(riverName),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 100, color: primaryColor),
              const SizedBox(height: 20),
              Text(
                "Validate Location for $riverName",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 6,
                ),
                icon: const Icon(Icons.verified, size: 26, color: Colors.white),
                label: const Text(
                  "Validate Location",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UploadReadingPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
