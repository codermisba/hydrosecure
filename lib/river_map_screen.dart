import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class RiverMapScreen extends StatefulWidget {
  const RiverMapScreen({super.key});

  @override
  State<RiverMapScreen> createState() => _RiverMapScreenState();
}

class _RiverMapScreenState extends State<RiverMapScreen> {
  final geoJson = GeoJsonParser(); // ✅ correct class name
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRiverData();
  }

  Future<void> _loadRiverData() async {
    try {
      // 🗺️ Public GeoJSON for India's river network
      final url = Uri.parse(
        'https://raw.githubusercontent.com/geohacker/india/master/india_rivers.geojson',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        geoJson.parseGeoJson(data); // ✅ correct method
      } else {
        debugPrint('⚠️ Failed to load river data');
      }
    } catch (e) {
      debugPrint('Error loading river data: $e');
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("India River Map"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(22.9734, 78.6569), // Center of India
                initialZoom: 5.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.hydrosecure',
                ),
                PolylineLayer(
                  polylines: geoJson.polylines
                      .map((p) => Polyline(
                            points: p.points,
                            color: Colors.blueAccent,
                            strokeWidth: 2.5,
                          ))
                      .toList(),
                ),
              ],
            ),
    );
  }
}
