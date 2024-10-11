import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calculate_distance.dart';

class GazCalculate extends StatefulWidget {
  const GazCalculate({super.key});

  @override
  GazCalculateState createState() => GazCalculateState();
}

class GazCalculateState extends State<GazCalculate> {
  final locController = TextEditingController();
  final cities = <Map<String, dynamic>>[].obs;
  final addLocation = false.obs;
  final getLocations = false.obs;
  bool _isRestored = false;
  var isFetchingLocation = false.obs;
  var locationAdded = false.obs;
  String? selectedCarModel;
  String? selectedCC;
  TextEditingController fuelPriceController = TextEditingController();

  final List<String> carModels = [
    'Toyota', 'Honda', 'Ford', 'Chevrolet', 'Nissan',
    'Hyundai', 'Kia', 'Volkswagen', 'Subaru', 'Mazda',
    'BMW', 'Mercedes-Benz', 'Audi', 'Lexus'
  ];

  final List<String> engineCapacities = [
    '1000 CC', '1200 CC', '1400 CC', '1600 CC', '1800 CC',
    '2000 CC', '2200 CC', '2400 CC', '2600 CC', '2800 CC',
    '3000 CC', '3200 CC'
  ];

  @override
  void initState() {
    super.initState();
    locController.addListener(_updateAddLocationState);
    _loadSavedData();
  }

  @override


  void dispose() {
    locController.removeListener(_updateAddLocationState);
    locController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load cities
    String? citiesJson = prefs.getString('cities');
    if (citiesJson != null) {
      final List<dynamic> decodedCities = jsonDecode(citiesJson);
      cities.assignAll(List<Map<String, dynamic>>.from(decodedCities));
    }

    // Load car model
    selectedCarModel = prefs.getString('selectedCarModel');

    // Load CC
    selectedCC = prefs.getString('selectedCC');

    // Load fuel price
    final savedFuelPrice = prefs.getString('fuelPrice');
    if (savedFuelPrice != null) {
      fuelPriceController.text = savedFuelPrice;
    }

    // Trigger a rebuild of the widget
    setState(() {});
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save cities
    String citiesJson = jsonEncode(cities.toList());
    await prefs.setString('cities', citiesJson);

    // Save car model
    if (selectedCarModel != null) {
      await prefs.setString('selectedCarModel', selectedCarModel!);
    }

    // Save CC
    if (selectedCC != null) {
      await prefs.setString('selectedCC', selectedCC!);
    }

    // Save fuel price
    await prefs.setString('fuelPrice', fuelPriceController.text);
  }


  void _updateAddLocationState() {
    addLocation.value = locController.text.isNotEmpty;
  }

  void _handleGeocodingError(String errorMessage) {
    Get.snackbar(
      'Error',
      'Unable to find location.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  void _addCityToList(Location location) {
    // Define Egypt's geographical boundaries
    const double minLat = 22.0;
    const double maxLat = 31.5;
    const double minLon = 25.0;
    const double maxLon = 35.0;

    // Check if the location is within Egypt's boundaries
    if (location.latitude < minLat ||
        location.latitude > maxLat ||
        location.longitude < minLon ||
        location.longitude > maxLon) {
      Get.snackbar(
        'Error',
        'Enter a location in Egypt.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      _saveData();
      return;
    }

    // Add the city if it is within Egypt
    cities.add({
      'name': locController.text,
      'lat': location.latitude,
      'lng': location.longitude,
    });
    locController.clear();
    addLocation.value = false;
    Get.snackbar('Success',
        'Location added: ${location.latitude}, ${location.longitude}');
    _saveData();
  }

  void navigateToLocationsList() {
    if (cities.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LocationsListPage(locations: cities)),
      );
    } else {
      Get.snackbar('Error', 'Please add at least one location',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void navigateToCalculateDistance() {
    if (cities.isNotEmpty) {
      if (selectedCarModel == null || selectedCC == null || fuelPriceController.text.isEmpty) {
        Get.snackbar('Error', 'Please select a car model, CC, and enter fuel price',
            snackPosition: SnackPosition.TOP);
      } else {
        double fuelPrice = double.parse(fuelPriceController.text);
        Get.to(() => CalculateDistance(
          locations: cities,
          carModel: selectedCarModel!,
          carCC: selectedCC!,
          fuelPrice: fuelPrice,
        ));
      }
    } else {
      Get.snackbar('Error', 'Please add at least one location',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = cities.removeAt(oldIndex);
    cities.insert(newIndex, item);
  }

  void _undoDeletion(Map<String, dynamic> deletedItem, int index) {
    // Check for duplicates before adding the deleted item back
    final exists = cities.any((city) => city['name'] == deletedItem['name']);
    if (!exists) {
      // Add the deleted item back to the list only if it doesn't already exist
      cities.insert(index, deletedItem);
      Get.snackbar(
          duration: const Duration(seconds: 1),
          'Restored',
          'Location restored: ${deletedItem['name']}');
    } else {
      Get.snackbar('Error', 'This location already exists in the list.');
    }
  }

  void _addLocationFromCoordinates(double latitude, double longitude, String locationName) {
    const double minLat = 22.0;
    const double maxLat = 31.5;
    const double minLon = 25.0;
    const double maxLon = 35.0;

    // Check if the location is within Egypt's boundaries
    if (latitude < minLat ||
        latitude > maxLat ||
        longitude < minLon ||
        longitude > maxLon) {
      Get.snackbar(
        'Error',
        'Your current location is not in Egypt.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Add the user's current location to the cities list
    cities.add({
      'name': locationName,
      'lat': latitude,
      'lng': longitude,
    });

    // Show a success message with the actual location name
    Get.snackbar(
      'Success',
      'Your current location ($locationName) has been added: ($latitude, $longitude)',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  void removeLocation(String locationName) {
    // Remove location from cities list
    cities.removeWhere((city) => city['name'] == locationName);

    // Check if the location was successfully removed
    if (!cities.any((city) => city['name'] == locationName)) {
      locationAdded.value = false; // Re-enable the button
    }
    _saveData();
  }

  Future<void> _determinePosition() async {
    if (isFetchingLocation.value || locationAdded.value) return; // Prevent adding location multiple times

    isFetchingLocation.value = true; // Set fetching state to true

    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Error', 'Location services are disabled.');
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Error', 'Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Error', 'Location permissions are permanently denied.');
        return;
      }

      // Fetch the current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Reverse geocoding to get the location name
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      // Get the city or location name from the placemark
      String locationName = placemarks[0].locality ?? 'Unnamed Location';

      // Add the fetched location to the list
      _addLocationFromCoordinates(
          position.latitude, position.longitude, locationName);

      // Disable the button after adding the location
      locationAdded.value = true;

      // Close the dialog if it's open
      Navigator.of(context).pop();

    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch location: $e');
    } finally {
      isFetchingLocation.value = false; // Reset fetching state
    }
  }

  Future<void> addLocationWithCoordinates() async {
    if (locController.text.isNotEmpty) {
      try {
        List<Location> locations =
        await locationFromAddress(locController.text);
        if (locations.isNotEmpty) {
          // Check for duplicates
          final locationName = locController.text;

          final exists = cities.any((city) =>
          city['name'].toLowerCase() == locationName.toLowerCase());

          if (exists) {
            Get.snackbar(
              'Error',
              'This location already exists in the list.',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 3),
            );
          } else {
            _addCityToList(locations.first);
          }
        } else {
          _handleGeocodingError('No locations found');
        }
      } catch (e) {
        developer.log('Geocoding error: $e');
        _handleGeocodingError(e.toString());
      }
    }
  }

  void _showAddLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter the address or use current location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: locController,
                onChanged: (text) {
                  addLocation.value = text.isNotEmpty;
                },
                decoration: InputDecoration(
                  labelText: 'Enter location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              SizedBox(height: 8,),
              TextButton(
                onPressed: () {
                  _determinePosition(); // This will now add the location and close the dialog
                },
                child: const Text('Use current location'),
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Obx(() {
                    return TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: addLocation.value
                            ? Colors.green
                            : Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: addLocation.value
                          ? () {
                        addLocationWithCoordinates();
                        Navigator.of(context).pop();
                      }
                          : null,
                      child: const Text('Add'),
                    );
                  }),
                ),
              ],
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('City List',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        elevation: 4,
        leading: const Icon(Icons.location_city),
        actions: [
          Obx(() => IconButton(
                icon: isFetchingLocation.value
                    ? CircularProgressIndicator() // Show spinner while fetching
                    : const Icon(Icons.location_on_rounded ,color: Colors.teal,),
                onPressed: locationAdded.value
                    ? null
                    : _determinePosition, // Disable button after location is added
                tooltip: 'Use current location',
              )),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('About This App'),
                    content: const Text(
                      'This app allows you to add locations, view them in a list, '
                      'and calculate the shortest route between them. '
                      'You can enter city names or addresses, and the app will '
                      'geocode them to get coordinates. The app then uses these '
                      'coordinates to calculate distances and optimize the route.',
                      textAlign: TextAlign.justify,
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end, // Align children to the end (right)
        children: [
          FloatingActionButton(
            heroTag: 'addButton',
            onPressed: () {
              _showAddLocationDialog(context);
            },
            backgroundColor: Colors.teal,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16), // Add some space between the buttons
          SizedBox(
            width:  MediaQuery.of(context).size.width * 0.92, // Make the button take full width
            child: Obx(() => ElevatedButton.icon(
              onPressed: cities.isNotEmpty ? navigateToCalculateDistance : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: cities.isNotEmpty ? Colors.teal : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.calculate, color: Colors.white),
              label: const Text('Calculate', style: TextStyle(color: Colors.white)),
            )),
          ),
        ],
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Car model and engine capacity dropdowns
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    DropdownButton<String>(
                      value: selectedCarModel,
                      items: carModels.map((String model) {
                        return DropdownMenuItem<String>(
                          value: model,
                          child: Text(model),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCarModel = newValue;
                          _saveData();
                        });
                      },
                      hint: const Text('Select a car model'),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: selectedCC,
                      items: engineCapacities.map((String cc) {
                        return DropdownMenuItem<String>(
                          value: cc,
                          child: Text(cc),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCC = newValue;
                          _saveData();
                        });
                      },
                      hint: const Text('Select a car CC'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Fuel price input
                // Fuel price input and clear button row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: fuelPriceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Enter Fuel Price',
                          hintText: 'Fuel price per liter',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.local_gas_station),
                        ),
                        onChanged: (value) {
                          setState(() {
                            var fuelPrice = double.tryParse(value) ?? 0.0;
                            _saveData();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10), // Space between the TextField and button
                    Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cities.isNotEmpty ? Colors.teal : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),

                        ),
                        disabledBackgroundColor: Colors.grey, // Set disabled background color
                        disabledForegroundColor: Colors.white, // Set disabled foreground color
                      ),
                      onPressed: cities.isNotEmpty ? () {
                        setState(() {
                          cities.clear(); // Clear the list of cities
                        });
                      } : null, // Disable button if cities list is empty
                      child: const Text('Clear', style: TextStyle(color: Colors.white)),
                    ),)
                  ],
                ),

                const SizedBox(height: 20),
                // Display locations or message if none added
                Obx(() {
                  if (cities.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: const Text(
                        'No locations added yet. Please add a location.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.6,
                      ),
                      child: ReorderableListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), // Prevents internal scrolling
                        onReorder: _onReorder,
                        children: [
                          for (int index = 0; index < cities.length; index++)
                            Dismissible(
                              key: ValueKey(cities[index]['name']),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                final deletedItem = cities[index];
                                final deletedIndex = index;
                                cities.removeAt(index);
                                _isRestored = false;

                                Get.snackbar(
                                  '${deletedItem['name']} Deleted',
                                  'You have deleted this location',
                                  snackPosition: SnackPosition.BOTTOM,
                                  mainButton: TextButton(
                                    onPressed: _isRestored ? () {} : () {
                                      HapticFeedback.lightImpact();
                                      _undoDeletion(deletedItem, deletedIndex);
                                      setState(() {
                                        _isRestored = true;
                                      });
                                    },
                                    child: Text(
                                      'Restore',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                );
                              },
                              child: ListTile(
                                key: ValueKey(cities[index]['name']),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal[100],
                                  child: const Icon(Icons.location_on, color: Colors.teal),
                                ),
                                title: Text(
                                  cities[index]['name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Lat: ${cities[index]['lat'].toStringAsFixed(4)}, Lng: ${cities[index]['lng'].toStringAsFixed(4)}',
                                ),
                                trailing: const Icon(Icons.drag_handle),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 50), // Space to prevent overlap with floating buttons
              ],
            ),
          ),
        ),
      ),

    );
  }
}

class LocationsListPage extends StatelessWidget {
  final List<Map<String, dynamic>> locations;

  const LocationsListPage({Key? key, required this.locations})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Locations List')),
      body: ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(locations[index]['name']),
            subtitle: Text(
                'Lat: ${locations[index]['lat']}, Lng: ${locations[index]['lng']}'),
          );
        },
      ),
    );
  }
}




