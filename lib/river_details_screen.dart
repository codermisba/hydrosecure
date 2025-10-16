import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'upload_reading_page.dart';
import 'theme.dart';
import 'components.dart';

class RiverDetailScreen extends StatefulWidget {
  final String riverName;
  const RiverDetailScreen({super.key, required this.riverName});

  @override
  State<RiverDetailScreen> createState() => _RiverDetailScreenState();
}

class _RiverDetailScreenState extends State<RiverDetailScreen> {
  // Demo Godavari stations
  List<Map<String, String>> godavariStations = [
    {
      "sNo": "1",
      "site": "Betmogrra",
      "district": "Nanded",
      "ho": "HO",
      "catchment": "2105",
      "river": "Godavari/ Manjira/ Manar",
      "type": "GDQ",
      "date": "01/06/1997,03/07/1997,15/07/1997",
      "lat": "18.705",
      "lon": "77.545",
      "code": "AGP10F7"
    },
    {
      "sNo": "2",
      "site": "Degloor",
      "district": "Nanded",
      "ho": "HO",
      "catchment": "1900",
      "river": "Godavari/ Manjira/ Lendi",
      "type": "GDSQ",
      "date": "16/08/1984,17/07/1987,01/01/1994,15/09/1988",
      "lat": "18.562",
      "lon": "77.583",
      "code": "AGP20F4"
    },
    {
      "sNo": "3",
      "site": "Dhalegaon",
      "district": "Parbhani",
      "ho": "HO",
      "catchment": "30840",
      "river": "Godavari",
      "type": "GDSQ",
      "date": "04/01/1964,16/08/1964,11/07/1971,01/07/1972",
      "lat": "19.220",
      "lon": "76.363",
      "code": "AG000S9"
    },
  ];

  List<Map<String, String>> filteredStations = [];
  Map<String, String>? selectedStation;
  TextEditingController searchController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController siteController = TextEditingController();
  TextEditingController latController = TextEditingController();
  TextEditingController lonController = TextEditingController();

  double? userLat, userLon, stationLat, stationLon, distance;
  


  @override
  void initState() {
    super.initState();
    if (widget.riverName.toLowerCase() == "godavari") {
      filteredStations = godavariStations;
    }
    searchController.addListener(_filterStations);
    _updateUserLocation();
  }

  @override
  void dispose() {
    searchController.dispose();
    stateController.dispose();
    siteController.dispose();
    latController.dispose();
    lonController.dispose();
    super.dispose();
  }

  void _filterStations() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredStations = godavariStations
          .where((station) =>
              station['site']!.toLowerCase().contains(query) ||
              station['district']!.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _updateUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        userLat = position.latitude;
        userLon = position.longitude;
      });
    } catch (e) {
      setState(() {
        userLat = null;
        userLon = null;
      });
    }
  }

  Future<void> _showMessage(String title, String message) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }

  Future<void> _validateLocation() async {
    if (widget.riverName.toLowerCase() == "godavari" &&
        selectedStation == null) {
      _showMessage("Validation Failed", "Please select a gauge station.");
      return;
    }

    if (widget.riverName.toLowerCase() != "godavari") {
      if (stateController.text.isEmpty ||
          siteController.text.isEmpty ||
          latController.text.isEmpty ||
          lonController.text.isEmpty) {
        _showMessage("Validation Failed",
            "Please enter state, site name, latitude, and longitude.");
        return;
      }
      stationLat = double.tryParse(latController.text);
      stationLon = double.tryParse(lonController.text);
      if (stationLat == null || stationLon == null) {
        _showMessage("Validation Failed", "Invalid latitude or longitude.");
        return;
      }
    } else {
      stationLat = double.tryParse(selectedStation!['lat']!);
      stationLon = double.tryParse(selectedStation!['lon']!);
    }

    if (userLat == null || userLon == null) {
      await _updateUserLocation();
      if (userLat == null || userLon == null) {
        _showMessage("Error", "Unable to get your current location.");
        return;
      }
    }

    distance =
        Geolocator.distanceBetween(userLat!, userLon!, stationLat!, stationLon!);

    if (distance! <= 50) {
      _showMessage("Success",
          "You are within ${distance!.toStringAsFixed(2)} meters of the station.");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UploadReadingPage(
            station: widget.riverName.toLowerCase() == "godavari"
                ? selectedStation
                : {
                    "state": stateController.text,
                    "site": siteController.text,
                    "lat": "$stationLat",
                    "lon": "$stationLon",
                  },
          ),
        ),
      );
    } else {
      _showMessage("Validation Failed",
          "You are ${distance!.toStringAsFixed(2)} meters away from the station.\nMove closer to validate.");
    }
  }

  Widget _buildStationCard(Map<String, String> station) {
    bool isSelected = selectedStation == station;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.water, color: Colors.blue, size: 36),
        title: Text("${station['sNo']}. ${station['site']}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("District: ${station['district']}"),
            Text("Type: ${station['type']}, Catchment: ${station['catchment']} km²"),
            Text("River: ${station['river']}"),
            Text("Date Start: ${station['date']}"),
            Text("Lat: ${station['lat']}, Lon: ${station['lon']}"),
            Text("Code: ${station['code']}"),
          ],
        ),
        trailing:
            isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
        onTap: () {
          setState(() {
            selectedStation = station;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isGodavari = widget.riverName.toLowerCase() == "godavari";
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.riverName),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (userLat != null && userLon != null)
              Card(
                color: Colors.blue[50],
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: const Icon(Icons.my_location, color: Colors.blue),
                  title: Text(
                      "Your Location: ${userLat!.toStringAsFixed(5)}, ${userLon!.toStringAsFixed(5)}"),
                ),
              ),
            if (isGodavari)
              customTextField(
                  context: context,
                  controller: searchController,
                  hint: "Search by Station / District",
                  icon: Icons.search),
            const SizedBox(height: 16),
            Expanded(
              child: isGodavari
                  ? ListView.builder(
                      itemCount: filteredStations.length,
                      itemBuilder: (context, index) =>
                          _buildStationCard(filteredStations[index]),
                    )
                  : Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.edit_location,
                                size: 80, color: Colors.blue),
                            const SizedBox(height: 16),
                            customTextField(
                                context: context,
                                controller: stateController,
                                hint: "State",
                                icon: Icons.location_city),
                            customTextField(
                                context: context,
                                controller: siteController,
                                hint: "Site Name",
                                icon: Icons.location_on),
                            Row(
                              children: [
                                Expanded(
                                  child: customTextField(
                                      context: context,
                                      controller: latController,
                                      hint: "Latitude",
                                      icon: Icons.my_location),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: customTextField(
                                      context: context,
                                      controller: lonController,
                                      hint: "Longitude",
                                      icon: Icons.my_location),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            customButton("Validate Location", _validateLocation),
          ],
        ),
      ),
    );
  }
}
