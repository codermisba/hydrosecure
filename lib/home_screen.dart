import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hydrosecure/analytics_page.dart';
import 'package:hydrosecure/profile_page.dart';
import 'package:hydrosecure/river_details_screen.dart';
import 'package:hydrosecure/theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hydrosecure/river_map_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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

  String? selectedRiver;
  String? _locationMessage = "Fetching location...";
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _requestPermissions();
    }
  }

  /// Request permission only on mobile platforms
  Future<void> _requestPermissions() async {
    try {
      var status = await Permission.location.request();
      if (status.isGranted) {
        debugPrint("✅ Location permission granted");
      } else if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ Please grant location permission")),
        );
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    } catch (e) {
      debugPrint("Permission check failed: $e");
    }
  }

  /// Get location & address safely (works for web & mobile)
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationMessage = "Fetching location...";
    });

    try {
      if (!kIsWeb) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          setState(() {
            _locationMessage = "⚠️ Location services are disabled.";
            _isLoadingLocation = false;
          });
          return;
        }
      }

      LocationPermission permission;
      if (!kIsWeb) {
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            setState(() {
              _locationMessage = "⚠️ Location permission denied.";
              _isLoadingLocation = false;
            });
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          setState(() {
            _locationMessage = "🚫 Permission permanently denied.";
            _isLoadingLocation = false;
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      String latitude = position.latitude.toStringAsFixed(5);
      String longitude = position.longitude.toStringAsFixed(5);

      String readableAddress = "";
      try {
        final placemarks =
            await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          readableAddress =
              "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}".trim();
        }
      } catch (e) {
        readableAddress = "Address not available";
      }

      setState(() {
        _locationMessage =
            "Latitude: $latitude\nLongitude: $longitude\n$readableAddress";
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationMessage = "❌ Error getting location: $e";
        _isLoadingLocation = false;
      });
    }
  }

  void _showLocationDialog() async {
    await _getCurrentLocation();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Your Current Location",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          height: 100,
          child: Center(
            child: _isLoadingLocation
                ? const CircularProgressIndicator()
                : SingleChildScrollView(
                    child: Text(
                      _locationMessage ?? "Unable to fetch location",
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
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
      MaterialPageRoute(builder: (context) => AnalyticsDashboardPage()),
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
        leading: IconButton(
          icon: const Icon(Icons.location_on, color: Colors.white, size: 28),
          tooltip: 'Show Location',
          onPressed: _showLocationDialog,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 28, color: Colors.white),
            tooltip: 'Profile',
            onPressed: () {
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
                            Icon(Icons.analytics,
                                size: 60, color: Colors.orange),
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
            const SizedBox(height: 25),
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
                      leading:
                          const Icon(Icons.water_drop, color: Colors.blue),
                      title: Text(
                        rivers[index],
                        style: const TextStyle(fontSize: 18),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.grey),
                      onTap: () {
                        setState(() {
                          selectedRiver = rivers[index];
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
