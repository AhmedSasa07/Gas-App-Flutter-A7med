import 'package:flutter/material.dart';

class LocationsListPage extends StatelessWidget {
  final List<Map<String, dynamic>> locations;

  const LocationsListPage({super.key, required this.locations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Locations List')),
      body: ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(locations[index]['name']),
            subtitle: Text('Lat: ${locations[index]['lat']}, Lng: ${locations[index]['lng']}'),
          );
        },
      ),
    );
  }
}