import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/theme/aura_theme.dart';
import 'dart:async'; // Required for Timer

class LocationPicker extends StatefulWidget {
  final Function(double, double, String, String) onLocationSelected;

  const LocationPicker({required this.onLocationSelected, super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final TextEditingController _addressController = TextEditingController();
  Timer? _debounce;

  // Cleanup timer on close
  @override
  void dispose() {
    _addressController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Prevents hitting API too frequently (1 request per second policy)
  void _onSearchChanged(String query, LocationProvider provider) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      if (query.isNotEmpty) {
        provider.geocodeAddress(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FIND DELIVERY ADDRESS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: AuraTheme.secondary,
                ),
              ),
              const SizedBox(height: 16),

              // Address Input
              TextField(
                controller: _addressController,
                onChanged: (value) => _onSearchChanged(value, locationProvider),
                decoration: InputDecoration(
                  hintText: 'Search street, city, or landmark...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AuraTheme.primary,
                  ),
                  filled: true,
                  fillColor: AuraTheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _addressController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.grey),
                          onPressed: () {
                            _addressController.clear();
                            locationProvider.clearLocation();
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 12),

              // Quick Action: Current Location
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.my_location_rounded, size: 18),
                  label: const Text('Use My Current Location'),
                  onPressed: () => locationProvider.getCurrentLocation(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AuraTheme.primary,
                    side: const BorderSide(color: AuraTheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Loading State
              if (locationProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: AuraTheme.primary),
                  ),
                ),

              // Error State
              if (locationProvider.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          locationProvider.error!,
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Results Card
              if (locationProvider.latitude != null &&
                  !locationProvider.isLoading)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AuraTheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: AuraTheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location Found',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AuraTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        locationProvider.address ?? 'No address string found',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AuraTheme.onSurface,
                        ),
                      ),
                      const Divider(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          widget.onLocationSelected(
                            locationProvider.latitude!,
                            locationProvider.longitude!,
                            locationProvider.address ?? '',
                            locationProvider.city ?? 'Unknown',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AuraTheme.primary,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'CONFIRM AND CONTINUE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
