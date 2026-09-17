// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart'; // Import geocoding package

// class MapsScreen extends StatefulWidget {
//   final String placeName;

//   const MapsScreen({super.key, required this.placeName});

//   @override
//   _MapsScreenState createState() => _MapsScreenState();
// }

// class _MapsScreenState extends State<MapsScreen> {
//   late GoogleMapController mapController;
//   late LatLng _initialPosition;
//   Polygon? _zonePolygon; // Make _zonePolygon nullable

//   @override
//   void initState() {
//     super.initState();
//     _initialPosition =
//         LatLng(36.8065, 10.1815); // Default position (if place not found)
//     _getCoordinatesFromPlace(widget.placeName);
//   }

//   // Method to fetch the coordinates from the place name
//   Future<void> _getCoordinatesFromPlace(String placeName) async {
//     try {
//       List<Location> locations = await locationFromAddress(placeName);
//       log(locations.toString());
//       if (locations.isNotEmpty) {
//         setState(() {
//           _initialPosition =
//               LatLng(locations[0].latitude, locations[0].longitude);
//         });

//         // Define a zone around the place (for demonstration: a fixed distance of 0.01 degrees)
//         _zonePolygon = _createRectangle(_initialPosition);

//         // Adjust the camera to focus on the center of the rectangle
//         mapController
//             .animateCamera(CameraUpdate.newLatLngZoom(_initialPosition, 14));
//       }
//     } catch (e) {
//       print("Error fetching coordinates: $e");
//     }
//   }

//   // Create a rectangle polygon (adjust size by changing the values)
//   Polygon _createRectangle(LatLng center) {
//     double offset =
//         0.006; // This offset value defines the size of the rectangle
//     List<LatLng> polygonCoords = [
//       LatLng(center.latitude + offset, center.longitude - offset), // Top-left
//       LatLng(center.latitude + offset, center.longitude + offset), // Top-right
//       LatLng(
//           center.latitude - offset, center.longitude + offset), // Bottom-right
//       LatLng(
//           center.latitude - offset, center.longitude - offset), // Bottom-left
//     ];

//     return Polygon(
//       polygonId: PolygonId('zone_polygon'),
//       points: polygonCoords,
//       strokeColor: Colors.blue,
//       strokeWidth: 2,
//       fillColor: Colors.blue.withOpacity(0.2), // Semi-transparent fill
//     );
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _zonePolygon == null
//         ? Center(
//           //   child: SvgPicture.asset(
//           //   'assets/icons/logo_boon.svg',
//           //   colorFilter:
//           //       ColorFilter.mode(AppColor.primaryColor, BlendMode.srcIn),
//           // ))
//         )
//         : Stack(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(10.r),
//                 child: GoogleMap(
//                   myLocationButtonEnabled: false,
//                   mapToolbarEnabled: false,
//                   zoomControlsEnabled: false,
//                   zoomGesturesEnabled: false,
//                   onMapCreated: _onMapCreated,
//                   initialCameraPosition: CameraPosition(
//                     target: _initialPosition,
//                     zoom: 13,
//                   ),
//                   polygons: _zonePolygon != null ? {_zonePolygon!} : {},
//                 ),
//               ),
//             ],
//           );
//   }
// }