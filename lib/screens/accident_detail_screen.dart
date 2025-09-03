import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AccidentDetailScreen extends StatelessWidget {
  final String imageUrl;
  final String timestamp;
  final double latitude;
  final double longitude;
  final String accidentId;

  const AccidentDetailScreen({
    super.key,
    required this.imageUrl,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.accidentId,
  });

  Future<void> _updateAccidentStatus(BuildContext context, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection("accidents-info")
          .doc(accidentId)
          .update({"status": status});
      
      // Don't pop immediately to show the success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                status == "responded" ? Icons.check_circle : Icons.info_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text("Successfully marked as $status"),
            ],
          ),
          backgroundColor: status == "responded" ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(8),
        ),
      );
      
      // Delayed navigation
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.pop(context);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text("Error updating status: $e"),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(8),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng accidentLocation = LatLng(latitude, longitude);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        children: [
          // Stack the image with gradient overlay
          Stack(
            children: [
              // Image at the top
              Image.network(
                imageUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        const Text("Image unavailable", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
              // Gradient overlay
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              // Positioned text at the bottom of the image
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Text(
                  "Emergency Response Needed",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 3.0, color: Colors.black)],
                  ),
                ),
              ),
            ],
          ),
          
          // Content below the image
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Information section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Incident Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.grey[600], size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  timestamp,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.grey[600], size: 18),
                              const SizedBox(width: 8),
                              Text(
                                "Lat: ${latitude.toStringAsFixed(4)}, Lon: ${longitude.toStringAsFixed(4)}",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Map container
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: accidentLocation,
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('accident_location'),
                              position: accidentLocation,
                              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                            ),
                          },
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                          liteModeEnabled: true,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 28),
                    
                    // Action buttons
                    ElevatedButton.icon(
                      onPressed: () => _updateAccidentStatus(context, "responded"),
                      icon: const Icon(Icons.check_circle),
                      label: const Text("Respond Now"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    OutlinedButton.icon(
                      onPressed: () => _updateAccidentStatus(context, "false_alert"),
                      icon: const Icon(Icons.report_problem),
                      label: const Text("Report as False Alert"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        minimumSize: const Size(double.infinity, 56),
                        side: const BorderSide(color: Colors.redAccent, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}