import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/core_models.dart';
import '../services/database_service.dart';
import '../core/app_colors.dart';

class CinemaMapScreen extends StatefulWidget {
  const CinemaMapScreen({Key? key}) : super(key: key);

  @override
  State<CinemaMapScreen> createState() => _CinemaMapScreenState();
}

class _CinemaMapScreenState extends State<CinemaMapScreen> {
  final DatabaseService _db = DatabaseService();
  late GoogleMapController mapController;
  
  // Center roughly around Colombo
  final LatLng _colomboCenter = const LatLng(6.9271, 79.8612);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Cinemas'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<List<Cinema>>(
        stream: _db.getCinemasStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading map data: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cinemas = snapshot.data ?? [];
          
          // Generate Map Markers
          final Set<Marker> markers = cinemas.map((cinema) {
            return Marker(
              markerId: MarkerId(cinema.id),
              position: LatLng(cinema.latitude, cinema.longitude),
              infoWindow: InfoWindow(
                title: cinema.name,
                snippet: cinema.location,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
            );
          }).toSet();

          return GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _colomboCenter,
              zoom: 12.0,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          );
        },
      ),
    );
  }
}
