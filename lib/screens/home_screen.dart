import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'accident_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? userPosition;
  final double alertRadiusKm = 10.0;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userPosition = position;
    });
  }

  double _calculateDistance(lat1, lon1, lat2, lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Emergency Alerts",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54, size: 22),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: userPosition == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Getting your location...",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("accidents-info")
                    .orderBy("timestamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          const Text(
                            "Something went wrong",
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final accidents = snapshot.data!.docs.where((doc) {
                    try {
                      final lat = doc['location']['latitude'];
                      final lon = doc['location']['longitude'];
                      final status = doc['status'] ?? "unresolved";

                      if (status != "unresolved") return false;

                      final distance = _calculateDistance(
                        userPosition!.latitude,
                        userPosition!.longitude,
                        lat,
                        lon,
                      );
                      return distance <= alertRadiusKm;
                    } catch (_) {
                      return false;
                    }
                  }).toList();

                  if (accidents.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Colors.green[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No nearby incidents",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "You'll be notified when something happens within ${alertRadiusKm.toInt()} km",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: ListView.builder(
                      itemCount: accidents.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final accident = accidents[index];
                        final accidentType = accident['accident_type'] ?? "Accident";
                        final timestamp = accident['timestamp']?.toDate();
                        final formattedTime = timestamp != null
                            ? DateFormat.yMMMd().add_jm().format(timestamp)
                            : "Unknown time";

                        final lat = accident['location']['latitude']?.toStringAsFixed(4) ?? '0.0000';
                        final lon = accident['location']['longitude']?.toStringAsFixed(4) ?? '0.0000';
                        
                        final distance = _calculateDistance(
                          userPosition!.latitude,
                          userPosition!.longitude,
                          accident['location']['latitude'] ?? 0.0,
                          accident['location']['longitude'] ?? 0.0,
                        ).toStringAsFixed(1);

                        final icon = accidentType == "accident"
                            ? Icons.warning_amber_rounded
                            : Icons.info_outline_rounded;

                        final color = accidentType == "accident"
                            ? Colors.redAccent
                            : Colors.orangeAccent;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AccidentDetailScreen(
                                    imageUrl: accident['image_url'] ?? '',
                                    timestamp: timestamp?.toString() ?? 'Not available',
                                    latitude: accident['location']['latitude'] ?? 0.0,
                                    longitude: accident['location']['longitude'] ?? 0.0,
                                    accidentId: accident['accident_id'] ?? '',
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(icon, color: color, size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              accidentType.toUpperCase(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[50],
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                "$distance km",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue[800],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formattedTime,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Location: $lat, $lon",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.blue[700],
                                      size: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}