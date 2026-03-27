import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPicker extends StatefulWidget {
  final Function(double, double, String, String) onLocationSelected;
  final bool allowMapSelection;

  const LocationPicker({
    required this.onLocationSelected,
    this.allowMapSelection = true,
    Key? key,
  }) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address Input
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Search or Enter Address',
                hintText: 'e.g., Times Square, New York',
                prefixIcon: Icon(Icons.location_on),
                suffixIcon: _addressController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _addressController.clear();
                          locationProvider.clearLocation();
                        },
                      )
                    : null,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
              onSubmitted: (value) {
                locationProvider.geocodeAddress(value);
              },
            ),
            SizedBox(height: 10),

            // Search Button
            ElevatedButton.icon(
              icon: Icon(Icons.search),
              label: Text('Search Address'),
              onPressed: () {
                if (_addressController.text.isNotEmpty) {
                  locationProvider.geocodeAddress(_addressController.text);
                }
              },
            ),
            SizedBox(height: 10),

            // Current Location Button
            ElevatedButton.icon(
              icon: Icon(Icons.my_location),
              label: Text('Use Current Location'),
              onPressed: () {
                locationProvider.getCurrentLocation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 20),

            // Selected Location Display
            if (locationProvider.latitude != null)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Location',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 10),
                      Text(
                        locationProvider.address ?? 'Address not available',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'City: ${locationProvider.city ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Coordinates: ${locationProvider.latitude!.toStringAsFixed(4)}, ${locationProvider.longitude!.toStringAsFixed(4)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          widget.onLocationSelected(
                            locationProvider.latitude!,
                            locationProvider.longitude!,
                            locationProvider.address ?? '',
                            locationProvider.city ?? '',
                          );
                          Navigator.pop(context);
                        },
                        child: Text('Confirm Location'),
                      ),
                    ],
                  ),
                ),
              )
            else if (locationProvider.isLoading)
              Center(child: CircularProgressIndicator())
            else if (locationProvider.error != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error: ${locationProvider.error}',
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}
