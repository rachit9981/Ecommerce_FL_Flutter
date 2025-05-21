import 'package:flutter/material.dart';

class PhoneBrand {
  final String id;
  final String name;
  final String logoUrl;
  final List<PhoneModel> popularModels;

  PhoneBrand({
    required this.id,
    required this.name,
    required this.logoUrl, 
    this.popularModels = const [],
  });
}

class PhoneModel {
  final String id;
  final String brandId;
  final String name;
  final String imageUrl;
  final List<String> storageOptions;
  final List<String> conditions;
  final Map<String, double> estimatedPrices; // Based on storage and condition

  PhoneModel({
    required this.id,
    required this.brandId,
    required this.name,
    required this.imageUrl,
    this.storageOptions = const ['64GB', '128GB', '256GB'],
    this.conditions = const ['Like New', 'Good', 'Fair'],
    this.estimatedPrices = const {},
  });

  double getEstimatedPrice(String storage, String condition) {
    final key = '${storage}_$condition';
    return estimatedPrices[key] ?? 0.0;
  }
}

class BrandsGrid extends StatelessWidget {
  final List<PhoneBrand> brands;
  final Function(PhoneBrand) onBrandSelected;

  const BrandsGrid({
    Key? key, 
    required this.brands,
    required this.onBrandSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: brands.length,
      itemBuilder: (context, index) {
        return BrandItem(
          brand: brands[index],
          onTap: () => onBrandSelected(brands[index]),
        );
      },
    );
  }
}

class BrandItem extends StatelessWidget {
  final PhoneBrand brand;
  final VoidCallback onTap;

  const BrandItem({
    Key? key,
    required this.brand,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Brand logo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  brand.logoUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Brand name
            Text(
              brand.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class FeaturedBrandsRow extends StatelessWidget {
  final List<PhoneBrand> brands;
  final Function(PhoneBrand) onBrandSelected;

  const FeaturedBrandsRow({
    Key? key,
    required this.brands,
    required this.onBrandSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: brands.length,
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            child: BrandItem(
              brand: brands[index],
              onTap: () => onBrandSelected(brands[index]),
            ),
          );
        },
      ),
    );
  }
}

class PhoneBrandsData {
  static List<PhoneBrand> getAllBrands() {
    return [
      PhoneBrand(
        id: 'apple',
        name: 'Apple',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1667px-Apple_logo_black.svg.png',
      ),
      PhoneBrand(
        id: 'samsung',
        name: 'Samsung',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Samsung_Logo.svg/2560px-Samsung_Logo.svg.png',
      ),
      PhoneBrand(
        id: 'oneplus',
        name: 'OnePlus',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Oneplus-logo.jpg/2560px-Oneplus-logo.jpg',
      ),
      PhoneBrand(
        id: 'xiaomi',
        name: 'Xiaomi',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Xiaomi_logo_%282021-%29.svg/1024px-Xiaomi_logo_%282021-%29.svg.png',
      ),
      PhoneBrand(
        id: 'vivo',
        name: 'Vivo',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Vivo_logo.svg/1024px-Vivo_logo.svg.png',
      ),
      PhoneBrand(
        id: 'oppo',
        name: 'OPPO',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/OPPO_LOGO_2019.svg/2560px-OPPO_LOGO_2019.svg.png',
      ),
      PhoneBrand(
        id: 'realme',
        name: 'Realme',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Realme_logo.svg/2560px-Realme_logo.svg.png',
      ),
      PhoneBrand(
        id: 'google',
        name: 'Google',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Google_2015_logo.svg/1200px-Google_2015_logo.svg.png',
      ),
      PhoneBrand(
        id: 'nokia',
        name: 'Nokia',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/Nokia_wordmark.svg/1200px-Nokia_wordmark.svg.png',
      ),
      PhoneBrand(
        id: 'motorola',
        name: 'Motorola',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/Motorola_logo.svg/1200px-Motorola_logo.svg.png',
      ),
      PhoneBrand(
        id: 'asus',
        name: 'Asus',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/ASUS_Logo.svg/1280px-ASUS_Logo.svg.png',
      ),
      PhoneBrand(
        id: 'htc',
        name: 'HTC',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/HTC_logo_2017.svg/1000px-HTC_logo_2017.svg.png',
      ),
    ];
  }
  
  static List<PhoneBrand> getFeaturedBrands() {
    // Just return the top 5 brands as featured
    return getAllBrands().take(5).toList();
  }
  
  static List<PhoneModel> getPopularModels() {
    return [
      PhoneModel(
        id: 'iphone_14_pro_max',
        brandId: 'apple',
        name: 'iPhone 14 Pro Max',
        imageUrl: 'https://img.freepik.com/free-psd/smartphone-mockup_1310-812.jpg',
        estimatedPrices: {
          '128GB_Like New': 65000.0,
          '128GB_Good': 55000.0,
          '128GB_Fair': 45000.0,
          '256GB_Like New': 75000.0,
          '256GB_Good': 65000.0,
          '256GB_Fair': 55000.0,
        },
      ),
      PhoneModel(
        id: 'galaxy_s23_ultra',
        brandId: 'samsung',
        name: 'Galaxy S23 Ultra',
        imageUrl: 'https://img.freepik.com/free-psd/smartphone-mockup_1310-812.jpg',
        estimatedPrices: {
          '256GB_Like New': 70000.0,
          '256GB_Good': 60000.0,
          '256GB_Fair': 50000.0,
        },
      ),
      PhoneModel(
        id: 'oneplus_11',
        brandId: 'oneplus',
        name: 'OnePlus 11',
        imageUrl: 'https://img.freepik.com/free-psd/smartphone-mockup_1310-812.jpg',
        estimatedPrices: {
          '128GB_Like New': 45000.0,
          '128GB_Good': 38000.0,
          '128GB_Fair': 30000.0,
        },
      ),
      PhoneModel(
        id: 'pixel_7_pro',
        brandId: 'google',
        name: 'Pixel 7 Pro',
        imageUrl: 'https://img.freepik.com/free-psd/smartphone-mockup_1310-812.jpg',
        estimatedPrices: {
          '128GB_Like New': 50000.0,
          '128GB_Good': 42000.0,
          '128GB_Fair': 35000.0,
        },
      ),
    ];
  }
}
