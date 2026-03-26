enum ItemCondition { newItem, likeNew, used, fair }

extension ItemConditionLabel on ItemCondition {
  String get label {
    switch (this) {
      case ItemCondition.newItem:
        return 'New';
      case ItemCondition.likeNew:
        return 'Like New';
      case ItemCondition.used:
        return 'Used';
      case ItemCondition.fair:
        return 'Fair';
    }
  }

  int get value {
    switch (this) {
      case ItemCondition.newItem:
        return 4;
      case ItemCondition.likeNew:
        return 3;
      case ItemCondition.used:
        return 2;
      case ItemCondition.fair:
        return 1;
    }
  }
}

class ListingDraft {
  String? imagePath;
  String title;
  String category;
  double? price;
  String description;
  String serialNumber;
  ItemCondition condition;
  String location;

  ListingDraft({
    this.imagePath,
    this.title = '',
    this.category = 'Electronics',
    this.price,
    this.description = '',
    this.serialNumber = '',
    this.condition = ItemCondition.newItem,
    this.location = '',
  });
}
