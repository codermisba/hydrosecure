import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hydrosecure/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';


class UploadReadingPage extends StatefulWidget {
  const UploadReadingPage({Key? key}) : super(key: key);

  @override
  State<UploadReadingPage> createState() => _UploadReadingPageState();
}

class _UploadReadingPageState extends State<UploadReadingPage> {
  bool isManual = false;
  File? _capturedImage;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController waterLevelController = TextEditingController();
  final TextEditingController streamFlowController = TextEditingController();
  final TextEditingController temperatureController = TextEditingController();
  final TextEditingController turbidityController = TextEditingController();
  final TextEditingController rainfallController = TextEditingController();

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission is required!")),
      );
    }
  }

  Future<void> _captureImage() async {
    await _requestCameraPermission();
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _capturedImage = File(pickedImage.path);
      });
    }
  }

  Widget _buildTelemetryField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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

  Widget _buildManualForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTelemetryField(waterLevelController, "Water Level (m)", Icons.water_drop),
          _buildTelemetryField(streamFlowController, "Stream Flow (m³/s)", Icons.waves),
          _buildTelemetryField(temperatureController, "Temperature (°C)", Icons.thermostat),
          _buildTelemetryField(turbidityController, "Turbidity (NTU)", Icons.blur_on),
          _buildTelemetryField(rainfallController, "Rainfall (mm)", Icons.cloudy_snowing),
          const SizedBox(height: 20),
          Center(child: _buildCaptureButton()), // ✅ Center aligned button
          const SizedBox(height: 16),
          if (_capturedImage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  _capturedImage!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Reading submitted successfully!")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              elevation: 3,
            ),
            child: const Text(
              "Submit Reading",
              style: TextStyle(fontSize: 17, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return ElevatedButton.icon(
      onPressed: _captureImage,
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 14),
        elevation: 3,
      ),
      icon: const Icon(Icons.camera_alt, color: Colors.white),
      label: const Text(
        "Capture Live Image",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _buildLiveUpload() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Click Live Image of Gauge Post",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        Center(child: _buildCaptureButton()), // ✅ Centered button
        const SizedBox(height: 20),
        if (_capturedImage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                _capturedImage!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
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
      body: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Toggle buttons
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(14),
                fillColor: primaryColor,
                selectedColor: Colors.white,
                color: Colors.black87,
                constraints:
                    const BoxConstraints(minWidth: 150, minHeight: 45),
                isSelected: [!isManual, isManual],
                onPressed: (index) {
                  setState(() {
                    isManual = index == 1;
                    _capturedImage = null;
                  });
                },
                children: const [
                  Text("Live Upload", style: TextStyle(fontSize: 16)),
                  Text("Manual Entry", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isManual ? _buildManualForm() : _buildLiveUpload(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
