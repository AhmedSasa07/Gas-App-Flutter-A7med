// import 'dart:developer' as developer;
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:get/get.dart';
// import 'calculate_distance.dart';
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
//   String? selectedCarModel;
//   String? selectedCC;
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
//         List<Location> locations =
//         await locationFromAddress(locController.text);
//         if (locations.isNotEmpty) {
//           _addCityToList(locations.first);
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
//     cities.add({
//       'name': locController.text,
//       'lat': location.latitude,
//       'lng': location.longitude,
//     });
//     locController.clear();
//     addLocation.value = false;
//     Get.snackbar('Success',
//       'Location added',snackPosition: SnackPosition.BOTTOM,);
//   }
//
//   // void navigateToLocationsList() {
//   //   if (cities.isNotEmpty) {
//   //     Navigator.push(
//   //       context,
//   //       MaterialPageRoute(
//   //           builder: (context) => LocationsListPage(locations: cities)),
//   //     );
//   //   }
//   // }
//
//   void navigateToCalculateDistance() {
//     if (cities.isNotEmpty) {
//       Get.to(() => CalculateDistance(locations: cities));
//     } else {
//       Get.snackbar('Error', 'Please add at least one location', snackPosition: SnackPosition.BOTTOM);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('City List', style: TextStyle(fontWeight: FontWeight.bold)),
//         backgroundColor: Colors.teal,
//         elevation: 4,
//         leading: const Icon(Icons.location_city),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.info_outline),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return AlertDialog(
//                     title: const Text('About This App'),
//                     content: const Text(
//                         'This app allows you to add locations, view them in a list, '
//                             'and calculate the shortest route between them. '
//                             'You can enter city names or addresses, and the app will '
//                             'geocode them to get coordinates. The app then uses these '
//                             'coordinates to calculate distances and optimize the route.'
//                     ),
//                     actions: <Widget>[
//                       TextButton(
//                         child: const Text('Close'),
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.teal.shade50, Colors.white],
//           ),
//         ),
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 TextField(
//                   controller: locController,
//                   decoration: InputDecoration(
//                     labelText: 'Enter location',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                     prefixIcon: const Icon(Icons.search),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Obx(() => ElevatedButton.icon(
//                   onPressed: addLocation.value ? addLocationWithCoordinates : null,
//                   icon: const Icon(Icons.add_location),
//                   label: const Text('Add Location'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.teal,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 )),
//
//                 const SizedBox(height: 20),
//                 Obx(() {
//                   return ElevatedButton.icon(
//                     onPressed: cities.isNotEmpty ? navigateToCalculateDistance : null,
//                     icon: const Icon(Icons.calculate),
//                     label: const Text('Calculate'),
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.white, backgroundColor: cities.isNotEmpty ? Colors.blue : Colors.grey, // Text color
//                       elevation: cities.isNotEmpty ? 5 : 0, // Elevation effect when enabled
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12), // Rounded corners
//                       ),
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Padding for larger buttons
//                     ),
//                   );
//                 }),
//                 const SizedBox(height: 20),
//                 Card(
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: SizedBox(
//                     height: 300,
//                     child: Obx(() => ReorderableListView(
//                       onReorder: (oldIndex, newIndex) {
//                         setState(() {
//                           if (newIndex > oldIndex) newIndex--;
//                           final item = cities.removeAt(oldIndex);
//                           cities.insert(newIndex, item);
//                         });
//                       },
//                       children: List.generate(cities.length, (index) {
//                         return Dismissible(
//                           key: ValueKey(cities[index]['name']),
//                           background: Container(
//                             color: Colors.red,
//                             alignment: Alignment.centerRight,
//                             padding: const EdgeInsets.only(right: 20),
//                             child: const Icon(Icons.delete, color: Colors.white),
//                           ),
//                           direction: DismissDirection.endToStart,
//                           onDismissed: (direction) {
//                             cities.removeAt(index);
//                             Get.snackbar('Removed', 'City removed from the list',snackPosition: SnackPosition.BOTTOM,);
//                           },
//                           child: ListTile(
//                             key: ValueKey(cities[index]['name']),
//                             leading: CircleAvatar(
//                               backgroundColor: Colors.teal[100],
//                               child: const Icon(Icons.location_on, color: Colors.teal),
//                             ),
//                             title: Text(
//                               cities[index]['name'],
//                               style: const TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             subtitle: Text(
//                               'Lat: ${cities[index]['lat'].toStringAsFixed(4)}, Lng: ${cities[index]['lng'].toStringAsFixed(4)}',
//                             ),
//                             trailing: const Icon(Icons.drag_handle), // Drag handle icon
//                           ),
//                         );
//                       }),
//                     )),
//                   ),
//                 ),
//                 const SizedBox(height: 20,),
//                 DropdownButton<String>(
//                   value: selectedCarModel, // Set the current value of the dropdown
//                   items: const <DropdownMenuItem<String>>[
//                     DropdownMenuItem<String>(value: 'Toyota ', child: Text('Toyota ')),
//                     DropdownMenuItem<String>(value: 'Honda ', child: Text('Honda ')),
//                     DropdownMenuItem<String>(value: 'Ford ', child: Text('Ford ')),
//                     DropdownMenuItem<String>(value: 'Chevrolet ', child: Text('Chevrolet ')),
//                     DropdownMenuItem<String>(value: 'Nissan ', child: Text('Nissan ')),
//                     DropdownMenuItem<String>(value: 'Hyundai ', child: Text('Hyundai ')),
//                     DropdownMenuItem<String>(value: 'Kia ', child: Text('Kia ')),
//                     DropdownMenuItem<String>(value: 'Volkswagen ', child: Text('Volkswagen ')),
//                     DropdownMenuItem<String>(value: 'Subaru ', child: Text('Subaru ')),
//                     DropdownMenuItem<String>(value: 'Mazda', child: Text('Mazda')),
//                     DropdownMenuItem<String>(value: 'BMW ', child: Text('BMW ')),
//                     DropdownMenuItem<String>(value: 'Mercedes-Benz ', child: Text('Mercedes-Benz ')),
//                     DropdownMenuItem<String>(value: 'Audi ', child: Text('Audi ')),
//                     DropdownMenuItem<String>(value: 'Lexus ', child: Text('Lexus ')),
//                   ],
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       selectedCarModel = newValue; // Update the selected model
//                     });
//                   },
//                   hint: const Text('Select a car model'),
//                 ),
//                 // Display the selected car model in the menu bar
//                 if (selectedCarModel != null)
//                   Text('Selected Car Model: $selectedCarModel'),
//                 const SizedBox(height: 20),
//                 DropdownButton<String>(
//                   value: selectedCC,
//                   items: const <DropdownMenuItem<String>>[
//                     DropdownMenuItem<String>(value: '1000 CC', child: Text('1000 CC')),
//                     DropdownMenuItem<String>(value: '1200 CC', child: Text('1200 CC')),
//                     DropdownMenuItem<String>(value: '1400 CC', child: Text('1400 CC')),
//                     DropdownMenuItem<String>(value: '1600 CC', child: Text('1600 CC')),
//                     DropdownMenuItem<String>(value: '1800 CC', child: Text('1800 CC')),
//                     DropdownMenuItem<String>(value: '2000 CC', child: Text('2000 CC')),
//                     DropdownMenuItem<String>(value: '2200 CC', child: Text('2200 CC')),
//                     DropdownMenuItem<String>(value: '2400 CC', child: Text('2400 CC')),
//                     DropdownMenuItem<String>(value: '2600 CC', child: Text('2600 CC')),
//                     DropdownMenuItem<String>(value: '2800 CC', child: Text('2800 CC')),
//                     DropdownMenuItem<String>(value: '3000 CC', child: Text('3000 CC')),
//                     DropdownMenuItem<String>(value: '3200 CC', child: Text('3200 CC')),
//                   ],
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       selectedCC = newValue; // Update the selected CC
//                     });
//                   },
//                   hint: const Text('Select a car CC'),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // class LocationsListPage extends StatelessWidget {
// //   final List<Map<String, dynamic>> locations;
//
// //   const LocationsListPage({super.key, required this.locations});
//
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Locations List')),
// //       body: ListView.builder(
// //         itemCount: locations.length,
// //         itemBuilder: (context, index) {
// //           return ListTile(
// //             title: Text(locations[index]['name']),
// //             subtitle: Text(
// //                 'Lat: ${locations[index]['lat']}, Lng: ${locations[index]['lng']}'),
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
