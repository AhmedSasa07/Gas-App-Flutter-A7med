// import 'dart:developer' as developer;
//
// import 'package:animation_search_bar/animation_search_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
//
// import 'calculate_distance.dart'; // Add this import at the top of the file
//
// class GazCalculate extends StatefulWidget {
//   const GazCalculate({super.key});
//
//   @override
//   GazCalculateState createState() => GazCalculateState();
// }
//
// class GazCalculateState extends State<GazCalculate> {
//   final locController = TextEditingController();
//   final cities = <Map<String, dynamic>>[].obs;
//   final addLocation = false.obs;
//   final getLocations = false.obs;
//   bool _isRestored = false;
//   var isFetchingLocation = false.obs;
//   var locationAdded = false.obs;
//
//   @override
//   void initState() {
//     super.initState();
//     locController.addListener(_updateAddLocationState);
//   }
//
//   @override
//   void dispose() {
//     locController.removeListener(_updateAddLocationState);
//     locController.dispose();
//     super.dispose();
//   }
//
//   void _updateAddLocationState() {
//     addLocation.value = locController.text.isNotEmpty;
//   }
//
//   Future<void> addLocationWithCoordinates() async {
//     if (locController.text.isNotEmpty) {
//       try {
//         List<Location> locations = await locationFromAddress(locController.text);
//         if (locations.isNotEmpty) {
//           // Check for duplicates
//           final locationName = locController.text;
//
//           final exists = cities.any((city) => city['name'].toLowerCase() == locationName.toLowerCase());
//
//           if (exists) {
//             Get.snackbar(
//               'Error',
//               'This location already exists in the list.',
//               snackPosition: SnackPosition.BOTTOM,
//               duration: const Duration(seconds: 3),
//             );
//           } else {
//             _addCityToList(locations.first);
//           }
//         } else {
//           _handleGeocodingError('No locations found');
//         }
//       } catch (e) {
//         developer.log('Geocoding error: $e');
//         _handleGeocodingError(e.toString());
//       }
//     }
//   }
//
//
//   void _handleGeocodingError(String errorMessage) {
//     Get.snackbar(
//       'Error',
//       'Unable to find location. Please check your input and try again.',
//       snackPosition: SnackPosition.BOTTOM,
//       duration: const Duration(seconds: 3),
//     );
//   }
//
//   void _addCityToList(Location location) {
//     // Define Egypt's geographical boundaries
//     const double minLat = 22.0;
//     const double maxLat = 31.5;
//     const double minLon = 25.0;
//     const double maxLon = 35.0;
//
//     // Check if the location is within Egypt's boundaries
//     if (location.latitude < minLat ||
//         location.latitude > maxLat ||
//         location.longitude < minLon ||
//         location.longitude > maxLon) {
//       Get.snackbar(
//         'Error',
//         'Enter a location in Egypt.',
//         snackPosition: SnackPosition.BOTTOM,
//         duration: const Duration(seconds: 3),
//       );
//       return;
//     }
//
//     // Add the city if it is within Egypt
//     cities.add({
//       'name': locController.text,
//       'lat': location.latitude,
//       'lng': location.longitude,
//     });
//     locController.clear();
//     addLocation.value = false;
//     Get.snackbar('Success',
//         'Location added: ${location.latitude}, ${location.longitude}');
//   }
//
//   void navigateToLocationsList() {
//     if (cities.isNotEmpty) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) => LocationsListPage(locations: cities)),
//       );
//     }
//   }
//
//   void navigateToCalculateDistance() {
//     if (cities.isNotEmpty) {
//       Get.to(() => CalculateDistance(locations: cities));
//     }
//   }
//
//   void _onReorder(int oldIndex, int newIndex) {
//     if (newIndex > oldIndex) {
//       newIndex -= 1;
//     }
//     final item = cities.removeAt(oldIndex);
//     cities.insert(newIndex, item);
//   }
//
//   void _undoDeletion(Map<String, dynamic> deletedItem, int index) {
//     // Check for duplicates before adding the deleted item back
//     final exists = cities.any((city) => city['name'] == deletedItem['name']);
//     if (!exists) {
//       // Add the deleted item back to the list only if it doesn't already exist
//       cities.insert(index, deletedItem);
//       Get.snackbar(duration:const Duration(seconds: 1),'Restored', 'Location restored: ${deletedItem['name']}');
//     } else {
//       Get.snackbar('Error', 'This location already exists in the list.');
//     }
//   }
//
//   Future<void> _determinePosition() async {
//     if (isFetchingLocation.value || locationAdded.value) return; // Prevent adding location multiple times
//
//     isFetchingLocation.value = true; // Set fetching state to true
//
//     try {
//       bool serviceEnabled;
//       LocationPermission permission;
//
//       // Check if location services are enabled
//       serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         Get.snackbar('Error', 'Location services are disabled.');
//         isFetchingLocation.value = false;
//         return;
//       }
//
//       permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           Get.snackbar('Error', 'Location permissions are denied.');
//           isFetchingLocation.value = false;
//           return;
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         Get.snackbar('Error', 'Location permissions are permanently denied.');
//         isFetchingLocation.value = false;
//         return;
//       }
//
//       // Fetch the current position
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//
//       // Reverse geocoding to get the location name
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//           position.latitude, position.longitude);
//
//       // Get the city or location name from the placemark
//       String locationName = placemarks[0].locality ?? 'Unnamed Location';
//
//       // Add the fetched location to the list
//       _addLocationFromCoordinates(position.latitude, position.longitude, locationName);
//
//       // Disable the button after adding the location
//       locationAdded.value = true;
//
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to fetch location: $e');
//     } finally {
//       isFetchingLocation.value = false; // Reset fetching state
//     }
//   }
//
//   void _addLocationFromCoordinates(double latitude, double longitude, String locationName) {
//     const double minLat = 22.0;
//     const double maxLat = 31.5;
//     const double minLon = 25.0;
//     const double maxLon = 35.0;
//
//     // Check if the location is within Egypt's boundaries
//     if (latitude < minLat || latitude > maxLat || longitude < minLon || longitude > maxLon) {
//       Get.snackbar(
//         'Error',
//         'Your current location is not in Egypt.',
//         snackPosition: SnackPosition.BOTTOM,
//         duration: const Duration(seconds: 3),
//       );
//       return;
//     }
//
//     // Add the user's current location to the cities list
//     cities.add({
//       'name': locationName,
//       'lat': latitude,
//       'lng': longitude,
//     });
//
//     // Show a success message with the actual location name
//     Get.snackbar(
//       'Success',
//       'Your current location ($locationName) has been added: ($latitude, $longitude)',
//       snackPosition: SnackPosition.BOTTOM,
//       duration: const Duration(seconds: 3),
//     );
//   }
//
//   void removeLocation(String locationName) {
//     // Remove location from cities list
//     cities.removeWhere((city) => city['name'] == locationName);
//
//     // Check if the location was successfully removed
//     if (!cities.any((city) => city['name'] == locationName)) {
//       locationAdded.value = false; // Re-enable the button
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('City List'),
//         actions: [
//           Obx(() => IconButton(
//             icon: isFetchingLocation.value
//                 ? CircularProgressIndicator() // Show spinner while fetching
//                 : const Icon(Icons.location_on_rounded),
//             onPressed: locationAdded.value ? null : _determinePosition, // Disable button after location is added
//             tooltip: 'Use current location',
//           )),
//         ],
//       ),
//       body: Column(
//         children: [
//
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: locController,
//               onChanged: (text) {
//                 // Update the observable to true when text is entered, false otherwise
//                 addLocation.value = text.isNotEmpty;
//               },
//               decoration: InputDecoration(
//                 labelText: 'Enter location',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 suffixIcon: Obx(() {
//                   return Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         onPressed: addLocation.value ? addLocationWithCoordinates : null,
//                         icon: const Icon(Icons.add_sharp),
//                         color: addLocation.value ? Colors.green : Colors.grey,
//                         disabledColor: Colors.grey,
//                         focusColor: Colors.lightGreenAccent,
//                       ),
//
//                     ],
//                   );
//                 }),
//               ),
//             ),
//           ),
//
//           const SizedBox(
//             height: 20,
//           ),
//
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Obx(() {
//                 return ElevatedButton.icon(
//                   onPressed: cities.isNotEmpty || getLocations.value
//                       ? navigateToLocationsList
//                       : null,
//                   icon: const Icon(Icons.location_on_sharp),
//                   label: const Text('Locations List'),
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white, backgroundColor: (cities.isNotEmpty || getLocations.value) ? Colors.green : Colors.grey, // Text color
//                     elevation: (cities.isNotEmpty || getLocations.value) ? 5 : 0, // Elevation effect when enabled
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12), // Rounded corners
//                     ),
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Padding for larger buttons
//                   ),
//                 );
//               }),
//               // const SizedBox(
//               //   height: 20,
//               // ),
//               Obx(() {
//                 return ElevatedButton.icon(
//                   onPressed: cities.isNotEmpty ? navigateToCalculateDistance : null,
//                   icon: const Icon(Icons.calculate),
//                   label: const Text('Calculate'),
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white, backgroundColor: cities.isNotEmpty ? Colors.blue : Colors.grey, // Text color
//                     elevation: cities.isNotEmpty ? 5 : 0, // Elevation effect when enabled
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12), // Rounded corners
//                     ),
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Padding for larger buttons
//                   ),
//                 );
//               }),
//             ],
//           ),
//
//           Expanded(
//             child: Obx(() {
//               return ReorderableListView(
//                 onReorder: _onReorder,
//                 children: [
//                   for (int index = 0; index < cities.length; index++)
//                     Dismissible(
//                       key: ValueKey(cities[index]['name']),
//                       background: Container(
//                         color: Colors.red,
//                         alignment: Alignment.centerRight,
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: const Icon(
//                           Icons.delete,
//                           color: Colors.white,
//                         ),
//                       ),
//                       direction: DismissDirection.endToStart,
//                       onDismissed: (direction) {
//                         final deletedItem = cities[index];
//                         final deletedIndex = index;
//                         cities.removeAt(index);
//
//                         // Reset the restore status whenever a new deletion occurs
//                         _isRestored = false;
//
//                         // Show the Snackbar
//                         Get.snackbar(
//                           'Deleted',
//                           '${deletedItem['name']} has been deleted.',
//                           duration: const Duration(seconds: 3),
//                           mainButton: TextButton(
//                             onPressed: _isRestored ? null : () { // Disable if already restored
//                               HapticFeedback.lightImpact();
//                               _undoDeletion(deletedItem, deletedIndex);
//                               setState(() {
//                                 _isRestored = true; // Mark as restored
//                               });
//                             },
//                             child: const Text('Restore'),
//                           ),
//                         );
//                       },
//                       child: ListTile(
//                         title: Text(cities[index]['name']),
//                         // subtitle: Text(
//                         //   'Lat: ${cities[index]['lat']}, Lng: ${cities[index]['lng']}',
//                         // ),
//                       ),
//                     ),
//                 ],
//               );
//             }),
//           ),
//
//           Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: SizedBox(
//               height: 300,
//               child: Obx(() => ReorderableListView(
//                 onReorder: (oldIndex, newIndex) {
//                   setState(() {
//                     if (newIndex > oldIndex) newIndex--;
//                     final item = cities.removeAt(oldIndex);
//                     cities.insert(newIndex, item);
//                   });
//                 },
//                 children: List.generate(cities.length, (index) {
//                   return Dismissible(
//                     key: ValueKey(cities[index]['name']),
//                     background: Container(
//                       color: Colors.red,
//                       alignment: Alignment.centerRight,
//                       padding: const EdgeInsets.only(right: 20),
//                       child: const Icon(Icons.delete, color: Colors.white),
//                     ),
//                     direction: DismissDirection.endToStart,
//                     onDismissed: (direction) {
//                       cities.removeAt(index);
//                       Get.snackbar('Removed', 'City removed from the list',snackPosition: SnackPosition.BOTTOM,);
//                     },
//                     child: ListTile(
//                       key: ValueKey(cities[index]['name']),
//                       leading: CircleAvatar(
//                         backgroundColor: Colors.teal[100],
//                         child: const Icon(Icons.location_on, color: Colors.teal),
//                       ),
//                       title: Text(
//                         cities[index]['name'],
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       subtitle: Text(
//                         'Lat: ${cities[index]['lat'].toStringAsFixed(4)}, Lng: ${cities[index]['lng'].toStringAsFixed(4)}',
//                       ),
//                       trailing: const Icon(Icons.drag_handle), // Drag handle icon
//                     ),
//                   );
//                 }),
//               )),
//             ),
//           ),
//
//         ],
//
//       ),
//
//     );
//
//   }
//
// }
//
// class LocationsListPage extends StatelessWidget {
//   final List<Map<String, dynamic>> locations;
//
//   const LocationsListPage({Key? key, required this.locations})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Locations List')),
//       body: ListView.builder(
//         itemCount: locations.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(locations[index]['name']),
//             subtitle: Text(
//                 'Lat: ${locations[index]['lat']}, Lng: ${locations[index]['lng']}'),
//           );
//         },
//       ),
//     );
//   }
// }
//
//
