import 'package:flutter/material.dart';
import 'dart:math';

class CalculateDistance extends StatefulWidget {
  final List<Map<String, dynamic>> locations;
  final String carModel;
  final String carCC;
  final double fuelPrice;

  const CalculateDistance({
    Key? key,
    required this.locations,
    required this.carModel,
    required this.carCC,
    required this.fuelPrice,

  }) : super(key: key);

  @override
  _CalculateDistanceState createState() => _CalculateDistanceState();
}

class _CalculateDistanceState extends State<CalculateDistance> {
  bool useUserInput = true; // Start with Recommended Route
  double costPerKm = 10.0;
  late List<int> shortestRoute;
  late double originalDistance;
  late double shortestDistance;
  final CarFuelCalculator fuelCalculator = CarFuelCalculator(); // Create an instance of CarFuelCalculator
  @override
  void initState() {
    super.initState();
    // Calculate routes and distances once during initialization
    shortestRoute = calculateShortestRoute(widget.locations);
    originalDistance = calculateTotalDistance(widget.locations, List.generate(widget.locations.length, (index) => index));
    shortestDistance = calculateTotalDistance(widget.locations, shortestRoute);
  }

  @override
  Widget build(BuildContext context) {
    // Determine the active distance and cost based on the toggle state
    double totalDistance = useUserInput ? shortestDistance : originalDistance;
    double totalFuelUsed = fuelCalculator.calculateFuelUsed(totalDistance, widget.carCC);
    double totalCost = totalFuelUsed * widget.fuelPrice;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Route Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 5,
      ),



      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text(useUserInput ? 'Recommended Route' : 'Original Route'),
              value: useUserInput,
              onChanged: (bool value) {
                setState(() {
                  useUserInput = value;
                });
              },
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car Model
                  Row(
                    children: [
                      Icon(Icons.directions_car, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        'Car Model: ${widget.carModel}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Engine Capacity
                  Row(
                    children: [
                      Icon(Icons.speed, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        'Engine Capacity: ${widget.carCC}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Fuel Price
                  Row(
                    children: [
                      Icon(Icons.local_gas_station, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        'Fuel Price: ${widget.fuelPrice.toStringAsFixed(2)} EGP/L',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Total Fuel Needed
                  Row(
                    children: [
                      Icon(Icons.opacity, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        'Total Fuel Needed: ${fuelCalculator.calculateFuelUsed(totalDistance, widget.carCC).toStringAsFixed(2)}L',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Total Distance
                  Row(
                    children: [
                      Icon(Icons.map, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        'Total Distance: ${totalDistance.toStringAsFixed(2)} km',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Total Cost
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        'Total Cost: ${totalCost.toStringAsFixed(2)} EGP',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Switch to toggle between Original and Recommended Routes

            Padding(
              padding: const EdgeInsets.symmetric(horizontal:16 ,vertical: 10.0),
              child: Text("Locations" , style: TextStyle(fontSize: 18),),
            ),
            Expanded(
              child: Card(
                child: ListView.builder(
                  itemCount: widget.locations.length,
                  itemBuilder: (context, index) {
                    // Display the route based on the toggle state
                    int cityIndex = useUserInput ? shortestRoute[index] : index;
                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.location_on, color: Colors.teal),
                          title: Text(
                            widget.locations[cityIndex]['name'],
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                          ),
                        ),

                        if (index < widget.locations.length - 1)
                          const Divider(
                            thickness: 0.5,
                            color: Colors.black,
                            height: 0.1,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Display total distance and cost



          ],
        ),
      ),
    );
  }

  List<int> calculateShortestRoute(List<Map<String, dynamic>> cities) {
    List<int> indices = List.generate(cities.length, (index) => index);
    List<int> shortestRoute = [];
    double shortestDistance = double.infinity;

    void permute(List<int> arr, int start) {
      if (start == arr.length - 1) {
        double distance = calculateTotalDistance(cities, arr);
        if (distance < shortestDistance) {
          shortestDistance = distance;
          shortestRoute = List.from(arr);
        }
        return;
      }

      for (int i = start; i < arr.length; i++) {
        List<int> newArr = List.from(arr);
        newArr[start] = arr[i];
        newArr[i] = arr[start];
        permute(newArr, start + 1);
      }
    }

    permute(indices, 1);
    return shortestRoute;
  }

  double calculateTotalDistance(List<Map<String, dynamic>> cities, List<int> route) {
    double totalDistance = 0;
    for (int i = 0; i < route.length - 1; i++) {
      totalDistance += calculateDistance(
        cities[route[i]]['lat'],
        cities[route[i]]['lng'],
        cities[route[i + 1]]['lat'],
        cities[route[i + 1]]['lng'],
      );
    }
    return totalDistance;
  }

  double calculateDistance(double? lat1, double? lng1, double? lat2, double? lng2) {
    if (lat1 == null || lng1 == null || lat2 == null || lng2 == null) {
      return 0;
    }

    const double earthRadius = 6371;
    double dLat = _toRadians(lat2 - lat1);
    double dLng = _toRadians(lng2 - lng1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  double calculateCost(double distance) {
    double fuelUsed = fuelCalculator.calculateFuelUsed(distance, widget.carCC);

    // Total cost is fuel used multiplied by the fuel price
    return fuelUsed * widget.fuelPrice;
  }


}

class CarFuelCalculator {
  // Base consumption for the smallest engine (1000 CC)
  final double baseConsumption = 5.0; // Base consumption (L/100 km) for 1000 CC

  // Consumption increase per 100 CC (e.g., 0.2 L/100 km per 100 CC increase)
  final double ccFactor = 0.2;

  // Function to calculate fuel consumption based on engine size (CC)
  double calculateFuelConsumption(String carCC) {
    // Parse the carCC string to extract the numeric value
    final int cc = int.parse(carCC.split(' ')[0]);

    // Calculate additional consumption based on the engine capacity
    double additionalConsumption = ccFactor * ((cc - 1000) / 100);

    // Total consumption
    return baseConsumption + additionalConsumption;
  }

  // Function to calculate fuel usage for a trip based on distance
  double calculateFuelUsed(double distance, String carCC) {
    double fuelConsumptionPer100Km = calculateFuelConsumption(carCC);

    // Calculate total fuel used for the given distance
    return (fuelConsumptionPer100Km / 100) * distance;
  }
}
