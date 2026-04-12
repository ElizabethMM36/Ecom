import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/location_provider.dart';
import '../../widgets/location_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostProductScreen extends StatefulWidget {
  @override
  State<PostProductScreen> createState() => _PostProductScreenState();
}

class _PostProductScreenState extends State<PostProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;

  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedAddress;
  String? _selectedCity;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
    _categoryController = TextEditingController();
  }

  Future<void> createProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLatitude == null || _selectedLongitude == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a location')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('YOUR_API_URL/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN',
        },
        body: jsonEncode({
          'title': _titleController.text,
          'category': _categoryController.text,
          'price': double.parse(_priceController.text),
          'description': _descriptionController.text,
          'condition': 'Like New', // Add selector
          'latitude': _selectedLatitude,
          'longitude': _selectedLongitude,
          'address': _selectedAddress,
          'city': _selectedCity,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Product listing created!')));
        Navigator.pop(context);
      } else {
        throw Exception('Failed to create product');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sell Product')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Form Fields
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Product Title'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              SizedBox(height: 20),

              // Location Picker
              Text(
                'Product Location',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 10),
              LocationPicker(
                onLocationSelected: (lat, lng, addr, city) {
                  setState(() {
                    _selectedLatitude = lat;
                    _selectedLongitude = lng;
                    _selectedAddress = addr;
                    _selectedCity = city;
                  });
                },
              ),
              SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : createProduct,
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('Create Listing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
