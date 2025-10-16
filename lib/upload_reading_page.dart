import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hydrosecure/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class UploadReadingPage extends StatefulWidget {
  const UploadReadingPage({Key? key, Map<String, String>? station}) : super(key: key);

  @override
  State<UploadReadingPage> createState() => _UploadReadingPageState();
}

class _UploadReadingPageState extends State<UploadReadingPage> {
  bool isManual = false;
  XFile? _pickedImage;
  Uint8List? _webImage;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController waterLevelController = TextEditingController();
  final TextEditingController streamFlowController = TextEditingController();
  final TextEditingController temperatureController = TextEditingController();
  final TextEditingController turbidityController = TextEditingController();
  final TextEditingController rainfallController = TextEditingController();

  double? userLat, userLon;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      Position position =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        userLat = position.latitude;
        userLon = position.longitude;
      });
    } catch (_) {
      setState(() {
        userLat = null;
        userLon = null;
      });
    }
  }

  Future<void> _requestCameraPermission() async {
    if (!kIsWeb) {
      var status = await Permission.camera.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        _showDialog("Permission Required", "Camera permission is required!");
      }
    }
  }

  Future<void> _captureImage() async {
    await _requestCameraPermission();
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImage = bytes;
          _pickedImage = picked;
        });
      } else {
        setState(() {
          _pickedImage = picked;
        });
      }
    }
  }

  Widget _buildImagePreview() {
    if (_pickedImage == null) return const SizedBox.shrink();
    if (kIsWeb && _webImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.memory(
          _webImage!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else if (_pickedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(
          File(_pickedImage!.path),
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _showDialog(String title, String message) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message),
                  const SizedBox(height: 8),
                  if (userLat != null && userLon != null)
                    Text(
                        "Your Location: ${userLat!.toStringAsFixed(5)}, ${userLon!.toStringAsFixed(5)}"),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context), child: const Text("OK"))
              ],
            ));
  }

  Widget _buildTelemetryField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: accentColor),
          filled: true,
          fillColor: Colors.blue.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: accentColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "Please enter $label" : null,
      ),
    );
  }

  void _submitManualEntry() {
    if (_formKey.currentState!.validate()) {
      _showDialog("Success", "Reading submitted successfully!");
      setState(() {
        _pickedImage = null;
        _webImage = null;
        waterLevelController.clear();
        streamFlowController.clear();
        temperatureController.clear();
        turbidityController.clear();
        rainfallController.clear();
      });
    }
  }

  void _submitLiveEntry() {
    if (_pickedImage != null) {
      _showDialog("Success", "Live reading submitted successfully!");
      setState(() {
        _pickedImage = null;
        _webImage = null;
      });
    } else {
      _showDialog("Error", "Please capture the image first!");
    }
  }

  Widget _buildManualForm() {
    return SingleChildScrollView(
      child: Center(
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Manual Entry",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor)),
                  const SizedBox(height: 16),
                  _buildTelemetryField(
                      waterLevelController, "Water Level (m)", Icons.water),
                  _buildTelemetryField(streamFlowController,
                      "Stream Flow (m³/s)", Icons.waves),
                  _buildTelemetryField(
                      temperatureController, "Temperature (°C)", Icons.thermostat),
                  _buildTelemetryField(
                      turbidityController, "Turbidity (NTU)", Icons.blur_on),
                  _buildTelemetryField(
                      rainfallController, "Rainfall (mm)", Icons.cloud),
                  const SizedBox(height: 16),
                  _buildImagePreview(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _captureImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Capture Image"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _submitManualEntry,
                        child: const Text("Submit"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                  if (userLat != null && userLon != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        "Your Location: ${userLat!.toStringAsFixed(5)}, ${userLon!.toStringAsFixed(5)}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveUpload() {
    return SingleChildScrollView(
      child: Center(
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Live Upload",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildImagePreview(),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _captureImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Capture Image"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitLiveEntry,
                  child: const Text("Submit"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  ),
                ),
                if (userLat != null && userLon != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      "Your Location: ${userLat!.toStringAsFixed(5)}, ${userLon!.toStringAsFixed(5)}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Reading"),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 3,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          ToggleButtons(
            borderRadius: BorderRadius.circular(14),
            fillColor: primaryColor,
            selectedColor: Colors.white,
            color: Colors.black87,
            constraints: const BoxConstraints(minWidth: 150, minHeight: 45),
            isSelected: [!isManual, isManual],
            onPressed: (index) {
              setState(() {
                isManual = index == 1;
                _pickedImage = null;
                _webImage = null;
              });
            },
            children: const [
              Text("Live Upload", style: TextStyle(fontSize: 16)),
              Text("Manual Entry", style: TextStyle(fontSize: 16)),
            ],
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isManual ? _buildManualForm() : _buildLiveUpload(),
            ),
          ),
        ],
      ),
    );
  }
}
