/*
// In your CreateListingScreen, replace your image picker call with:
final imagePath = await Navigator.push<String>(
  context,
  MaterialPageRoute(
    builder: (_) => ListingCameraScreen(
      expectedCategory: selectedCategory, // e.g. "Phone"
    ),
  ),
);
if (imagePath != null) setState(() => _capturedImagePath = imagePath);
```
*/
