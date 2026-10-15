class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> images;
  final List<String> sizes;
  final String category;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.images = const [],
    this.sizes = const [],
    this.category = '',
    this.stock = 100, // Default to 100 if not provided
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String imgUrl = '';
    List<String> parsedImages = [];
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      imgUrl = json['images'][0]['url'] ?? '';
      for (var img in json['images']) {
        if (img['url'] != null) {
          parsedImages.add(img['url']);
        }
      }
    }
    
    List<String> parsedSizes = [];
    if (json['sizes'] != null) {
      parsedSizes = List<String>.from(json['sizes']);
    }

    String categoryValue = '';
    if (json['category'] != null) {
      if (json['category'] is Map) {
        categoryValue = json['category']['name']?.toString() ?? '';
      } else {
        categoryValue = json['category'].toString();
      }
    }

    return Product(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Bánh ngọt',
      description: json['description']?.toString() ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: imgUrl,
      images: parsedImages,
      sizes: parsedSizes,
      category: categoryValue,
      stock: json['stock'] ?? json['countInStock'] ?? 100,
    );
  }

  double getPriceForSize(String size) {
    if (sizes.isEmpty) return price;
    int index = sizes.indexOf(size);
    if (index <= 0) return price; // First size or not found = base price
    if (index == 1) return price * 1.2; // Second size = +20%
    if (index == 2) return price * 1.5; // Third size = +50%
    return price * (1.0 + (index * 0.2)); // Generic scaling
  }
}
